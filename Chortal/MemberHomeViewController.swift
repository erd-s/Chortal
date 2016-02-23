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
    var completedArray: [CKRecord]?
    
    var taskArray = [CKRecord]()
    var currentOrganization: CKRecord?
    
    //MARK: Outlets
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items!.first! as UITabBarItem
        print("VDL TabBarItem: \(tabBar.selectedItem!.tag)")
        title = userDefaults.valueForKey("currentOrgName") as? String
        getOrganization()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //   tabBar.selectedItem?.tag = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        tabBar.selectedItem = tabBar.items?.first
    }
    
    
    //MARK: Custom Functions
    func getOrganization() {
        let predicate = NSPredicate(format: "uid == %@", orgID!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        print("query: \(query)")
        publicDatabase.performQuery(query, inZoneWithID: nil) { (organizations, error) -> Void in
            print("performing query, organizations: \(organizations![0]["name"])")
            self.currentOrganization = organizations![0] as CKRecord
            self.getTasks()
            self.getCurrentMember()
        }
    }
    
    func getTasks() {
        inProgressArray = [CKRecord]()
        completedArray = [CKRecord]()
        unclaimedArray = [CKRecord]()
        
        let taskReferenceArray = currentOrganization!.mutableArrayValueForKey("tasks")
        for taskRef in taskReferenceArray {
            publicDatabase.fetchRecordWithID(taskRef.recordID, completionHandler: { (task, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    //self.taskArray.append(task!)
                    if task!.valueForKey("inProgress") as? String == "true" {
                        self.inProgressArray?.append(task!)
                        print("claimed: \(task?.valueForKey("inProgress"))")
                        print("claimed: \(task?.valueForKey("completed"))")
                    } else {
                        if task!.valueForKey("completed") as? String == "true" {
                            self.completedArray?.append(task!)
                            print("completed: \(task?.valueForKey("inProgress"))")
                            print("completed: \(task?.valueForKey("completed"))")
                        } else {
                            self.unclaimedArray?.append(task!)
                            print("unclaimed: \(task?.valueForKey("inProgress"))")
                            print("unclaimed: \(task?.valueForKey("completed"))")
                            print("uncliamed: \(self.unclaimedArray?.count)")
                        }
                    }
                    
                    
                    print("got tasks")
                }
                
                if self.tabBar.selectedItem!.tag == 1 {
                    self.taskArray = self.unclaimedArray!
                } else if self.tabBar.selectedItem!.tag == 2 {
                    self.taskArray = self.inProgressArray!
                } else {
                    self.taskArray = self.completedArray!
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.taskTableView.reloadData()
                })
            })
        }
    }
    
    func getCurrentMember() {
        loadingAlert("Loading \(userDefaults.valueForKey("currentUserName")!)", viewController: self)
        for memberRef in currentOrganization!["members"] as! [CKReference] {
            publicDatabase.fetchRecordWithID(memberRef.recordID, completionHandler: { (memberRecord, error) -> Void in
                if memberRecord!["name"] as? String == userDefaults.valueForKey("currentUserName") as? String {
                    
                    currentUser = memberRecord
                    self.fetchTask()
                    
                    print("current user is set")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    //add spinner stuff & error handling
                }
            })
        }
    }
    func fetchTask() {
        func fetchRecord () {
            let taskRef = currentUser?.valueForKey("current_task") as! CKReference
            publicDatabase.fetchRecordWithID(taskRef.recordID) { (fetchedRecord, error) -> Void in
                if error != nil {
                    print("Error: \(error?.description)")
                } else {
                    if fetchedRecord != nil {
                        currentTask = fetchedRecord
                    }
                }
            }
        }
    }
    
    
    //MARK: IBActions
    @IBAction func menuButtonTapped(sender: UIBarButtonItem) {
    }
    
    //MARK: Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        if tabBar.selectedItem  == tabBar.items!.first! as UITabBarItem {
            taskArray = unclaimedArray!
        }
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.valueForKey("name") as? String
        cell.detailTextLabel?.text = task.valueForKey("description") as? String
        
        return cell
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        switch item.tag {
            
        case 1:
            taskArray = unclaimedArray!
            taskTableView.reloadData()
            break
            
        case 2:
            taskArray = inProgressArray!
            taskTableView.reloadData()
            break
            
        case 3:
            taskArray = completedArray!
            taskTableView.reloadData()
            break
            
        default:
            taskArray = unclaimedArray!
            taskTableView.reloadData()
            break
        }
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selIndexPath = tableView.indexPathForSelectedRow {
            
            let selectedCellSourceView = tableView.cellForRowAtIndexPath(selIndexPath)
            let selectedCellSourceRect = tableView.cellForRowAtIndexPath(selIndexPath)!.bounds
            
            let popOver = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("taskVC") as! TakeTaskViewController
            popOver.delegate = self
            popOver.task = taskArray[indexPath.row]
            popOver.organization = currentOrganization
            
            popOver.modalPresentationStyle = UIModalPresentationStyle.Popover
            popOver.popoverPresentationController?.backgroundColor = UIColor(red:0.93, green: 0.98, blue: 0.93, alpha:  1.00)
            
            popOver.popoverPresentationController?.delegate = self
            popOver.popoverPresentationController?.sourceView = selectedCellSourceView
            popOver.popoverPresentationController?.sourceRect = selectedCellSourceRect
            
            popOver.popoverPresentationController?.permittedArrowDirections = .Any
            
            popOver.preferredContentSize = CGSizeMake(320, 320)
            self.presentViewController(popOver, animated: true, completion: nil)
            
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func claimTaskPressed(claimedTask: CKRecord?) {
        let index = unclaimedArray?.indexOf(claimedTask!)
        unclaimedArray?.removeAtIndex(index!)
        inProgressArray?.append(claimedTask!)
        
    }
    
    
    
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "takeTaskSegue" {
            let indexPath = taskTableView.indexPathForCell(sender as! UITableViewCell)
            let dvc = segue.destinationViewController as! TakeTaskViewController
            dvc.task = taskArray[indexPath!.row]
            print("seguing task: \(dvc.task) over")
            dvc.organization = self.currentOrganization
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }
}
