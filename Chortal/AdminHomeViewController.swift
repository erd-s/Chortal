//
//  AdminHomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class AdminHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    var taskArray = [CKRecord]()
    var currentOrganization: CKRecord?
    
    //MARK: Outlets
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        title = userDefaults.valueForKey("currentOrgName") as! String

        getOrganization()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    //MARK: Custom Functions
    func getOrganization() {
        let predicate = NSPredicate(format: "uid == %@", orgID!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (organizations, error) -> Void in
            if error != nil {
                print(error)
            } else {
            print("performing query, organizations: \(organizations![0]["name"])")
            self.currentOrganization = organizations![0] as CKRecord
            self.getTasks()
            }
        }
    }
    
    func getTasks() {
        let taskReferenceArray = currentOrganization!.mutableArrayValueForKey("tasks")
        for taskRef in taskReferenceArray {
            publicDatabase.fetchRecordWithID(taskRef.recordID, completionHandler: { (task, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    if task != nil {
                    self.taskArray.append(task!)
                    print("appended task: \(task)")
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    //MARK: IBActions
    @IBAction func menuButtonTap(sender: AnyObject) {
    }
    
    @IBAction func createTaskButtonTap(sender: AnyObject) {
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
