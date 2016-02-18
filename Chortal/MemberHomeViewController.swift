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
    var userDefaults = NSUserDefaults.standardUserDefaults()
    var memberName: String?
    var orgID: String?
    var currentOrganization: CKRecord?
    
    
    //MARK: Outlets
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var taskTableView: UITableView!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        memberName = userDefaults.stringForKey("currentUserName")
        orgID = userDefaults.stringForKey("currentOrgUID")
        getOrganization()
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
                    print("appended task: \(task)")
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.taskTableView.reloadData()
                })
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
        cell.textLabel?.text = task.valueForKey("name") as? String
        cell.detailTextLabel?.text = task.valueForKey("description") as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    
    //MARK: Segues
    
}
