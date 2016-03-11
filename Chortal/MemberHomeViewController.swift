//
//  MemberHomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class MemberHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, UITabBarDelegate, ClaimTaskDelegate{
    
    //MARK: Properties
    var unclaimedArray: [CKRecord]?
    var inProgressArray: [CKRecord]?
    var pendingArray: [CKRecord]?
    var taskArray = [CKRecord]()
    var taskReferenceArray: NSMutableArray?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    let loadingView = LoadingView()
    
    
    //MARK: Outlets
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items!.first! as UITabBarItem
        title = userDefaults.valueForKey("currentOrgName") as? String
        
        taskTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        taskTableView.addSubview(refreshControl)
        loadingView.addLoadingViewToView(self, loadingText: "Updating tasks...")
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        tabBar.selectedItem = tabBar.items?.first
        getOrganization(true)
    }
    
    //MARK: Custom Functions
    func refresh (sender: AnyObject?) {
        refreshControl.enabled = false
        getOrganization(false)
    }
    
    func getOrganization(showLoadingAlert: Bool) {
        let predicate = NSPredicate(format: "uid == %@", orgUID!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        if showLoadingAlert {
            loadingView.hidden = false
            tabBar.userInteractionEnabled = false
        }
        
        publicDatabase.performQuery(query, inZoneWithID: nil) { (organizations, error) -> Void in
            if error != nil {
                checkError(error!, view: self)
            }
            currentOrg = organizations![0] as CKRecord
            userDefaults.setValue(currentOrg!["name"], forKey: "currentOrgName")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.getCurrentMember(showLoadingAlert)
            })
            
            
        }
    }
    
    func getTasks(shouldShowAlertController: Bool) {
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
                tabBarItemSwitch()
            } else {
                loadingView.hidden = true
                tabBar.userInteractionEnabled = true
                tabBarItemSwitch()
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
                    if (task!["member"] as! CKReference).recordID == currentMember?.recordID && currentTask == nil {
                        currentTask = task
                        var currentMemberTasks = [CKReference]()
                        var x = 0
                        if (currentMember!["current_tasks"] as! [CKReference]).count > 0 {
                            var currentMemberTasks = currentMember!["current_tasks"] as! [CKReference]
                            for task in currentMemberTasks {
                                if task.recordID == currentTask?.recordID {
                                    x++
                                }
                            }
                            
                            if x == 0 {
                                let newTaskRef = CKReference(record: currentTask!, action: .None)
                                currentMemberTasks.append(newTaskRef)
                                currentMember?.setValue(currentMemberTasks, forKey: "current_tasks")
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    publicDatabase.saveRecord(currentMember!, completionHandler: { (savedRecord, error) -> Void in
                                        if error != nil {
                                            print("Error Modifying the Current Member: \(error?.description)")
                                        } else {
                                            print("Current Member Was Updated Successfully")
                                        }
                                    })
                                })
                            }
                            
                        } else {
                            let newTaskRef = CKReference(record: currentTask!, action: .None)
                            currentMemberTasks.append(newTaskRef)
                            currentMember?.setValue(currentMemberTasks, forKey: "current_tasks")
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                publicDatabase.saveRecord(currentMember!, completionHandler: { (savedRecord, error) -> Void in
                                    if error != nil {
                                        print("Error Modifying the Current Member: \(error?.description)")
                                    } else {
                                        print("Current Member Was Updated Successfully")
                                    }
                                })
                            })
                            
                        }
                        
                        
                    }
                } else if task!.valueForKey("status") as? String == "pending"  {
                    self.pendingArray?.append(task!)
                } else if task?["status"] as? String == "unassigned" {
                    self.unclaimedArray?.append(task!)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if reference.isEqual(self.taskReferenceArray!.lastObject) {
                    if shouldShowAlertController == true {
                        self.loadingView.hidden = true
                        self.tabBar.userInteractionEnabled = true
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
    
    
    func getCurrentMember(showAlertController: Bool) {
        for memberRef in currentOrg!["members"] as! [CKReference] {
            publicDatabase.fetchRecordWithID(memberRef.recordID, completionHandler: { (memberRecord, error) -> Void in
                if memberRecord!["name"] as? String == userDefaults.valueForKey("currentUserName") as? String {
                    currentMember = memberRecord
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.getCurrentTaskForMember(showAlertController)
                    })
                    
                    print("current user is set")
                    if pushNotificationsSet == false {
                        setMemberPushNotifications()
                    }
                }
            })
        }
    }
    
    func getCurrentTaskForMember(showAlertController: Bool) {
        //        need to sort by metadata: modification date
        if currentMember?["current_tasks"] != nil {
            if (currentMember?["current_tasks"] as! [CKReference]).count > 0 {
                let taskRef = currentMember?["current_tasks"] as! [CKReference]
                publicDatabase.fetchRecordWithID(taskRef[0].recordID) { (fetchedRecord, error) -> Void in
                    if error != nil {
                        checkError(error!, view: self)
                    } else {
                        if fetchedRecord != nil {
                            currentTask = fetchedRecord
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.getTasks(showAlertController)
                        })
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.getTasks(showAlertController)
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.getTasks(showAlertController)
            })
        }
    }
    
    func tabBarItemSwitch(){
        switch tabBar.selectedItem!.tag {
            
        case 1:
            taskArray = unclaimedArray!
            taskTableView.reloadData()
            break
            
        case 2:
            taskArray = inProgressArray!
            taskTableView.reloadData()
            break
            
        case 3:
            taskArray = pendingArray!
            taskTableView.reloadData()
            break
            
        default:
            taskArray = unclaimedArray!
            taskTableView.reloadData()
            break
        }
    }
    
    //MARK: IBActions
    @IBAction func menuButtonTapped(sender: UIBarButtonItem) {
    }
    
    @IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
        getOrganization(true)
    }
    
    
    
    //MARK: Delegate Functions
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        tabBarItemSwitch()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        cell.backgroundColor = UIColor.clearColor()
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.valueForKey("name") as? String
        cell.detailTextLabel?.text = task.valueForKey("description") as? String
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        let view = UIView()
        view.frame = CGRectMake(cell.frame.origin.x + 10 , cell.frame.origin.y + 4, self.view.frame.width - 15, cell.layer.frame.height - 7)
        view.layer.borderColor = chortalGreen.CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
        view.backgroundColor = chortalGreen
        view.clipsToBounds = true
        cell.addSubview(view)
        cell.sendSubviewToBack(view)
        
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCellSourceView = tableView.cellForRowAtIndexPath(indexPath)
        let selectedCellSourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
        
        let popOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("taskVC") as! TakeTaskViewController
        popOver.delegate = self
        popOver.task = taskArray[indexPath.row]
        popOver.organization = currentOrg
        
        popOver.modalPresentationStyle = UIModalPresentationStyle.Popover
        popOver.popoverPresentationController?.backgroundColor = UIColor(red:0.93, green: 0.98, blue: 0.93, alpha:  1.00)
        
        popOver.popoverPresentationController?.delegate = self
        popOver.popoverPresentationController?.sourceView = selectedCellSourceView
        popOver.popoverPresentationController?.sourceRect = selectedCellSourceRect
        
        popOver.popoverPresentationController?.permittedArrowDirections = .Any
        
        popOver.preferredContentSize = CGSizeMake(320, 320)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(popOver, animated: true, completion: nil)
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func claimTaskPressed(claimedTask: CKRecord?) {
        let index = unclaimedArray?.indexOf(claimedTask!)
        let taskArrayIndex = taskArray.indexOf(claimedTask!)
        taskArray.removeAtIndex(taskArrayIndex!)
        unclaimedArray?.removeAtIndex(index!)
        inProgressArray?.append(claimedTask!)
        taskTableView.reloadData()
    }
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "takeTaskSegue" {
            let indexPath = taskTableView.indexPathForCell(sender as! UITableViewCell)
            let dvc = segue.destinationViewController as! TakeTaskViewController
            dvc.task = taskArray[indexPath!.row]
            print("seguing task: \(dvc.task) over")
            dvc.organization = currentOrg
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
    }
}
