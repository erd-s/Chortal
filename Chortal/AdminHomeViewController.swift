//
//  AdminHomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class AdminHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UIPopoverPresentationControllerDelegate {
    //MARK: Properties
    var taskArray = [CKRecord]()
    var unclaimedArray: [CKRecord]?
    var inProgressArray: [CKRecord]?
    var pendingArray: [CKRecord]?
    var taskReferenceArray: NSMutableArray?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    //MARK: Outlets
    
    @IBOutlet weak var newTaskBarButton: UIBarButtonItem!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items!.first! as UITabBarItem
        
        title = userDefaults.valueForKey("currentOrgName") as? String
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        menuButton.enabled = false
        newTaskBarButton.enabled = false
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBar.userInteractionEnabled = false
        
        isICloudContainerAvailable()

        getOrganization()
        
    }
    
    //MARK: Custom Functions
    func refresh (sender: AnyObject?) {
        
        getTasks(false)
        refreshControl.enabled = false
    }
    
    func getOrganization() {

        let predicate = NSPredicate(format: "uid == %@", orgUID!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (organizations, error) -> Void in
            if error != nil {
                checkError(error!, view: self)
            }
            else if organizations!.count == 0 {
                self.errorAlert("Error", message: "Organization not found.")
            } else if organizations?.count > 0 {
                currentOrg = organizations![0] as CKRecord
                self.loadingAlert("Loading tasks...", viewController: self)
                self.tabBar.userInteractionEnabled = true
                self.menuButton.enabled = true
                self.newTaskBarButton.enabled = true
                self.getTasks(true)
                self.getAdmin()
            }
        }
    }
    
    func getAdmin() {
        let adminRef = currentOrg!["admin"] as! CKReference
        publicDatabase.fetchRecordWithID(adminRef.recordID) { (adminRecord, error) -> Void in
            if error != nil {
                checkError(error!, view: self)
            } else {
                currentAdmin = adminRecord
                if pushNotificationsSet == false {
                    setAdminPushNotifications()
                }
            }
        }
    }
    func getTasks(shouldShowAlertController: Bool) {
    if let _ = NSFileManager.defaultManager().ubiquityIdentityToken {
            print("true")
        inProgressArray = [CKRecord]()
        pendingArray = [CKRecord]()
        unclaimedArray = [CKRecord]()
        
        taskReferenceArray = currentOrg!.mutableArrayValueForKey("tasks")
        if taskReferenceArray!.count > 0 {
            fetchTaskRecord(taskReferenceArray!.firstObject as! CKReference, shouldShowAlertController: shouldShowAlertController, indexNumber: 0)
        } else {
            if refreshControl.enabled == false {
                refreshControl.enabled = true
                refreshControl.endRefreshing()
            } else {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in

                })
                
            }
        }
        }
        }

        
    
    
    func fetchTaskRecord (reference: CKReference, shouldShowAlertController: Bool, indexNumber: Int) {
        publicDatabase.fetchRecordWithID(reference.recordID, completionHandler: { (task, error) -> Void in
            if error != nil {
                checkError(error!, view: self)
            } else {
                if task!.valueForKey("status") as? String == "inProgress"  || task!["status"] as? String == "rejected" {
                    self.inProgressArray?.append(task!)
                } else if task!.valueForKey("status") as? String == "pending"  {
                    self.pendingArray?.append(task!)
                } else if task?["status"] as? String == "unassigned" {
                    self.unclaimedArray?.append(task!)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if reference.isEqual(self.taskReferenceArray!.lastObject) {
                    if shouldShowAlertController == true {
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.menuButton.enabled = true
                            self.newTaskBarButton.enabled = true
                        })
                    } else {
                        self.refreshControl.endRefreshing()
                        self.refreshControl.enabled = true
                        
                    }
                    self.tabBarItemSwitch()
                    print(self.unclaimedArray!.count)
                    
                } else if !(self.taskReferenceArray![indexNumber].isEqual(self.taskReferenceArray?.lastObject))  {
                    
                    self.fetchTaskRecord(self.taskReferenceArray![indexNumber+1] as! CKReference, shouldShowAlertController: shouldShowAlertController, indexNumber: indexNumber + 1)
                }
            })
        })
    }
    
    func modifyRecordsOperation(record: CKRecord) {
        
        
    }
    
    func tabBarItemSwitch(){
        switch tabBar.selectedItem!.tag {
            
        case 1:
            taskArray = unclaimedArray!
            tableView.reloadData()
            break
            
        case 2:
            taskArray = inProgressArray!
            tableView.reloadData()
            break
            
        case 3:
            taskArray = pendingArray!
            tableView.reloadData()
            break
            
        default:
            taskArray = unclaimedArray!
            tableView.reloadData()
            break
        }
    }
    
    //MARK: IBActions
    
    //MARK: Delegate Functions
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        tabBarItemSwitch()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.valueForKey("name") as? String
        cell.detailTextLabel?.text = task.valueForKey("description") as? String
        
        let view = UIView()
        view.frame = CGRectMake(cell.frame.origin.x + 1, cell.frame.origin.y + 4, self.view.frame.width - 16, cell.layer.frame.height - 7)
        view.layer.borderColor = chortalGreen.CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
        view.backgroundColor = chortalGreen
        view.clipsToBounds = true
        cell.addSubview(view)
        cell.sendSubviewToBack(view)
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCellSourceView = tableView.cellForRowAtIndexPath(indexPath)
        let selectedCellSourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
        
        let popOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("taskVC") as! TakeTaskViewController
        
        popOver.task = taskArray[indexPath.row]
        popOver.organization = currentOrg
        
        popOver.modalPresentationStyle = UIModalPresentationStyle.Popover
        popOver.popoverPresentationController?.backgroundColor = UIColor(red:0.93, green: 0.98, blue: 0.93, alpha:  1.00)
        
        popOver.popoverPresentationController?.delegate = self
        popOver.popoverPresentationController?.sourceView = selectedCellSourceView
        popOver.popoverPresentationController?.sourceRect = selectedCellSourceRect
        
        popOver.popoverPresentationController?.permittedArrowDirections = .Any
        
        popOver.preferredContentSize = CGSizeMake(320, 260)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(popOver, animated: true, completion: nil)
            popOver.takeTaskButton.hidden = true
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            loadingAlert("Deleting record...", viewController: self)
            let deleteRecordID = [taskArray[indexPath.row].recordID] as [CKRecordID]
            
            taskArray.removeAtIndex(indexPath.row)
            
            let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: deleteRecordID)
            publicDatabase.addOperation(deleteOperation)
            deleteOperation.modifyRecordsCompletionBlock = { saved, deleted, error in
                if error != nil {
                    checkError(error!, view: self)
                } else {
                    print("Successfully deleted record")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                        })
                    })
                }
                
                
            }
        }
    }
    
    //MARK: Segues
    @IBAction func unwindFromTaskCreate (segue: UIStoryboardSegue) {
    }
    
}
