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
    
    //MARK: Outlets
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
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
        tableView.reloadData()

        
    }
    
    //MARK: Custom Functions
    func getOrganization() {
        let predicate = NSPredicate(format: "uid == %@", orgUID!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (organizations, error) -> Void in
            if error != nil {
                print("error getting current organization: \(error)")
            } else {
                currentOrg = organizations![0] as CKRecord
                self.getTasks()
                self.getAdmin()
            }
        }
    }
    
    func getAdmin() {
        let adminRef = currentOrg!["admin"] as! CKReference
        publicDatabase.fetchRecordWithID(adminRef.recordID) { (adminRecord, error) -> Void in
            if error != nil {
                print("error getting admin: \(error)")
            } else {
                currentAdmin = adminRecord
                if pushNotificationsSet == false {
                    setAdminPushNotifications()
                    userDefaults.setBool(true, forKey: "pushNotificationsSet")
                }
            }
        }
    }
    
    func getTasks() {
        let taskReferenceArray = currentOrg!.mutableArrayValueForKey("tasks")
        loadingAlert("Loading Tasks...", viewController: self)
        for taskRef in taskReferenceArray {
            publicDatabase.fetchRecordWithID(taskRef.recordID, completionHandler: { (task, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    if task != nil {
//--------------------->create arrays by status for the different tabs
                        self.taskArray.append(task!)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    if taskRef as? CKReference == taskReferenceArray.lastObject as? CKReference {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            })
        }
        if taskReferenceArray.count == 0 {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func modifyRecordsOperation(record: CKRecord) {
        
        
    }
    
    //MARK: IBActions
    
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
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            loadingAlert("Deleting record...", viewController: self)
            let deleteRecordID = [taskArray[indexPath.row].recordID] as [CKRecordID]
            
            taskArray.removeAtIndex(indexPath.row)
            
            let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: deleteRecordID)
            publicDatabase.addOperation(deleteOperation)
            deleteOperation.modifyRecordsCompletionBlock = { saved, deleted, error in
                if error != nil {
                    print("Error deleting record: \(error?.description)")
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
