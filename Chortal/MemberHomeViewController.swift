//
//  MemberHomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class MemberHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    var taskArray = [CKRecord]()
    var currentOrganization: CKRecord?
    
    //MARK: Outlets
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        title = userDefaults.valueForKey("currentOrgName") as? String
        getOrganization()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
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
        let taskReferenceArray = currentOrganization!.mutableArrayValueForKey("tasks")
        for taskRef in taskReferenceArray {
            publicDatabase.fetchRecordWithID(taskRef.recordID, completionHandler: { (task, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    self.taskArray.append(task!)
                    print("got tasks")
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
                    print("current user is set")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    //add spinner stuff & error handling
                }
            })
        }
    }
    
    
    //MARK: IBActions
    @IBAction func menuButtonTapped(sender: UIBarButtonItem) {
    }
    
    //MARK: Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.valueForKey("name") as? String
        cell.detailTextLabel?.text = task.valueForKey("description") as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
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
