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
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberOfTasksCompletedLabel: UILabel!
    @IBOutlet weak var currentTasksLabel: UILabel!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectedMember!["name"] as? String
        nameLabel.text = selectedMember!["name"] as? String
        
        let photoAsset = selectedMember!["profile_photo"] as? CKAsset
        profileImageView.image = UIImage(data: NSData(contentsOfURL: photoAsset!.fileURL)!)
    }
    
    //MARK: Custom Functions
    func getCompletedTasks() {
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
    
    func getCurrentTasks() {
        let arrayOfCurrentTasksReferences = selectedMember!["current_tasks"] as? [CKReference]
        for task in arrayOfCurrentTasksReferences! {
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
    }
    
    //MARK: IBActions
    
    //MARK: TableView Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        let taskAtIndex = arrayOfCompletedTasks[indexPath.row]
        cell.textLabel!.text = taskAtIndex["name"] as? String
        cell.detailTextLabel!.text = taskAtIndex["incentive"] as? String
        
        let view = UIView()
        view.frame = CGRectMake(cell.frame.origin.x + 5 , cell.frame.origin.y + 4, self.view.frame.width - 15, cell.layer.frame.height - 7)
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
        return arrayOfCompletedTasks.count
    }
    
    //MARK: Segues
    
}
