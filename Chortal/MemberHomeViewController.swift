//
//  MemberHomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

let container = CKContainer.defaultContainer()
let publicDatabase = container.publicCloudDatabase

class MemberHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    var taskArray = [CKRecord]()
    var userDefaults = NSUserDefaults.standardUserDefaults()
    var memberName: String?
    var currentOrganization: CKRecord?
    var arrayOfTasks: [CKRecord]?

    
    //MARK: Outlets
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var taskTableView: UITableView!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberName = userDefaults.stringForKey("currentUserName")
    }
    
    override func viewWillAppear(animated: Bool) {
        getOrganization()
    }
    
    
    //MARK: Custom Functions
    func getOrganization() {
        let predicate = NSPredicate(format: "member_list CONTAINS %@", memberName!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (organizations, error) -> Void in
        self.currentOrganization = organizations![0] as CKRecord
        self.getTasks()
        }
    }
    
    func getTasks() {
        let taskReferenceArray = currentOrganization!.mutableArrayValueForKey("tasks")
        for taskRef in taskReferenceArray {
            print(taskRef.recordName)
            let predicate = NSPredicate(format: "recordName = %@", taskRef.recordName)
            let query = CKQuery(recordType: "Task", predicate: predicate)
            publicDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (tasks, error) -> Void in
                self.taskArray = tasks!
                self.taskTableView.reloadData()
            })
        }
        }
    
    
    
    //MARK: IBActions
    @IBAction func menuButtonTapped(sender: UIBarButtonItem) {
    }
    
    @IBAction func myTaskButtonTap(sender: UIBarButtonItem) {
    }
    
    
    
    //MARK: Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task["name"] as? String
        cell.detailTextLabel?.text = task["description"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    
    //MARK: Segues
    
}
