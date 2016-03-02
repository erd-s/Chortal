//
//  MemberDetailViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 3/1/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class MemberDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    var arrayOfCompletedTasks = [CKRecord]()
    var arrayOfCurrentTasks = [CKRecord]()
    var selectedMember: CKRecord?
    
    //MARK: Outlets
    
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberOfTasksCompletedLabel: UILabel!
    @IBOutlet weak var currentTasksLabel: UILabel!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.title = selectedMember!["name"] as? String
        nameLabel.text = selectedMember!["name"] as? String
        self.currentTasksLabel.numberOfLines = 0
        
        let photoAsset = selectedMember!["profile_picture"] as? CKAsset
        profileImageView.image = UIImage(data: NSData(contentsOfURL: photoAsset!.fileURL)!)
        getCompletedTasks()
        getCurrentTasks()
    }
    
    //MARK: Custom Functions
    func getCompletedTasks() {
        if selectedMember!["finished_tasks"] != nil {
            let arrayOfCompletedTasksReferences = selectedMember!["finished_tasks"] as? [CKReference]
            for task in arrayOfCompletedTasksReferences! {
                publicDatabase.fetchRecordWithID(task.recordID, completionHandler: { (completedTask, error) -> Void in
                    if error != nil {
                        print("error: \(error)")
                    } else {
                        self.arrayOfCompletedTasks.append(completedTask!)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.numberOfTasksCompletedLabel.text = String(self.arrayOfCompletedTasks.count)
                            self.tableView.reloadData()
                        })
                    }
                    
                })
            }
        }
        else {
            self.numberOfTasksCompletedLabel.text = "0"
        }
    }
    
    func getCurrentTasks() {
        if selectedMember!["current_tasks"] != nil {
            if (selectedMember!["current_tasks"] as! [CKReference]).count != 0 {
                let arrayOfCurrentTasksReferences = selectedMember!["current_tasks"] as! [CKReference]
                for task in arrayOfCurrentTasksReferences {
                    publicDatabase.fetchRecordWithID(task.recordID, completionHandler: { (completedTask, error) -> Void in
                        if error != nil {
                            print("error: \(error)")
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let taskName = "\(completedTask!["name"]) \n"
                                self.currentTasksLabel.text = self.currentTasksLabel.text?.stringByAppendingString(taskName)
                            })
                        }
                    })
                }
            } else {
                self.currentTasksLabel.text = "No current tasks."
                self.currentTasksLabel.sizeToFit()
            }
        } else {
            self.currentTasksLabel.text = "No current tasks."
            self.currentTasksLabel.sizeToFit()
        }
    }
    
    //MARK: IBActions
    
    //MARK: TableView Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        if arrayOfCompletedTasks.count != 0 {
            let taskAtIndex = arrayOfCompletedTasks[indexPath.row]
            cell.textLabel!.text = taskAtIndex["name"] as? String
            cell.detailTextLabel!.text = taskAtIndex["incentive"] as? String
        } else {
            cell.textLabel!.text = "No completed tasks."
            cell.detailTextLabel!.text = nil
        }
        
        let view = UIView()
        view.frame = CGRectMake(cell.frame.origin.x + 5 , cell.frame.origin.y + 4, self.tableView.frame.width - 15, cell.layer.frame.height - 7)
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
        if arrayOfCompletedTasks.count != 0 {
            return arrayOfCompletedTasks.count
        } else {
            return 1
        }
    }
    
    //MARK: Segues
}
