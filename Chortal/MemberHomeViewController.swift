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
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    
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
        getOrganization()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        taskTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        if currentTask != nil {
            if currentTask!.valueForKey("status") as? String == "unassigned" {
                if inProgressArray != nil {
                    for task in inProgressArray! {
                        if task == currentTask {
                            let index = inProgressArray?.indexOf(task)
                            inProgressArray?.removeAtIndex(index!)
                            unclaimedArray?.append(task)
                            currentTask = nil
                            taskTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        tabBar.selectedItem = tabBar.items?.first
    }
    
    //MARK: Custom Functions
        func refresh (sender: AnyObject?) {
        getTasks()
        refreshControl.endRefreshing()
    }
    
    func getOrganization() {
        let predicate = NSPredicate(format: "uid == %@", orgUID!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (organizations, error) -> Void in
            currentOrg = organizations![0] as CKRecord
            self.getTasks()
            self.getCurrentMember()
        }
    }
    
    func getTasks() {
        inProgressArray = [CKRecord]()
        pendingArray = [CKRecord]()
        unclaimedArray = [CKRecord]()
        
        let taskReferenceArray = currentOrg!.mutableArrayValueForKey("tasks")
        for taskRef in taskReferenceArray {
            publicDatabase.fetchRecordWithID(taskRef.recordID, completionHandler: { (task, error) -> Void in
                if error != nil {
                    print("error fetching tasks: \(error)")
                } else {
                    if task!.valueForKey("status") as? String == "inProgress" {
                        self.inProgressArray?.append(task!)
                    } else if task!.valueForKey("status") as? String == "pending" {
                        self.pendingArray?.append(task!)
                    } else {
                        self.unclaimedArray?.append(task!)
                    }
                }
                print("got tasks")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tabBarItemSwitch()
                    self.taskTableView.reloadData()
                })
            })
        }
    }
    
    func getCurrentMember() {
        loadingAlert("Loading tasks...", viewController: self)
        for memberRef in currentOrg!["members"] as! [CKReference] {
            publicDatabase.fetchRecordWithID(memberRef.recordID, completionHandler: { (memberRecord, error) -> Void in
                if memberRecord!["name"] as? String == userDefaults.valueForKey("currentUserName") as? String {
                    currentMember = memberRecord
                    self.getCurrentTaskForMember()
                    print("current user is set")
                    if pushNotificationsSet == false {
                        setMemberPushNotifications()
                        userDefaults.setBool(true, forKey: "pushNotificationsSet")
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    func getCurrentTaskForMember() {
        //        need to sort by metadata: modification date
        if currentMember?["current_tasks"] != nil {
            if (currentMember?["current_tasks"] as! [CKReference]).count > 0 {
                let taskRef = currentMember?["current_tasks"] as! [CKReference]
                publicDatabase.fetchRecordWithID(taskRef[0].recordID) { (fetchedRecord, error) -> Void in
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
    
    //MARK: Delegate Functions
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        tabBarItemSwitch()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.valueForKey("name") as? String
        cell.detailTextLabel?.text = task.valueForKey("description") as? String
        
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
        self.presentViewController(popOver, animated: true, completion: nil)
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
