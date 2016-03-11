//
//  TakeTaskViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/20/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

protocol ClaimTaskDelegate {
    func claimTaskPressed (claimedTask: CKRecord?)
}

class TakeTaskViewController: UIViewController {
    //MARK: Properties
    var task: CKRecord?
    var photoRequiredYesOrNo: String?
    var dueDate: NSDate?
    var delegate: ClaimTaskDelegate?
    var organization: CKRecord?
    var loadingView = LoadingView()
    
    //MARK: Outlets
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var photoRequiredLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var takeTaskButton: UIButton!
    @IBOutlet weak var taskMemberLabel: UILabel!
    @IBOutlet weak var incentiveLabel: UILabel!
    @IBOutlet weak var commentsGreenLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if task?["photo_required"] as? String == "true" {
            photoRequiredYesOrNo = "are required"
        } else {
            photoRequiredYesOrNo = "are not required"
        }
        
        photoRequiredLabel.text = "Photos \(photoRequiredYesOrNo!)."
        if task!["description"] != nil && (task!["description"] as? String)?.characters.count > 0 {
            taskDescriptionLabel.text = task!["description"] as? String
        } else {
            taskDescriptionLabel.text = "None"
        }
        taskDescriptionLabel.sizeToFit()
        taskDescriptionLabel.numberOfLines = 0
        
        taskNameLabel.text = task!["name"] as? String
        incentiveLabel.text = task!["incentive"] as? String
        dueDate = task?["due"] as? NSDate
        let timeInterval = (dueDate?.timeIntervalSinceNow)! as NSTimeInterval
        
        if timeInterval < 0 {
            dueLabel.textColor = UIColor.redColor()
            dueLabel.text = "Past due!"
            
        } else if timeInterval < 3600 {
            let minutesRemaining = timeInterval / 60
            
            if Int(minutesRemaining) == 1 {
                dueLabel.text = "Due in \(Int(minutesRemaining)) minute!"
            } else {
                dueLabel.text = "Due in \(Int(minutesRemaining)) minutes!"
            }
            dueLabel.textColor = UIColor.orangeColor()
            
        } else if timeInterval < 86400 {
            let hoursRemaining = timeInterval / 3600
            
            if Int(hoursRemaining) == 1 {
                dueLabel.text = "Due in \(Int(hoursRemaining)) hour"
            } else {
                dueLabel.text = "Due in \(Int(hoursRemaining)) hours"
            }
            
        } else if timeInterval < 1209600 {
            let daysRemaining = timeInterval / 86400
            
            if Int(daysRemaining) == 1 {
                dueLabel.text = "Due in \(Int(daysRemaining)) day"
            } else {
                dueLabel.text = "Due in \(Int(daysRemaining)) days"
            }
            
        } else {
            let weeksRemaining = timeInterval / 604800
            
            if Int(weeksRemaining) == 1 {
                dueLabel.text = "Due in \(Int(weeksRemaining)) week"
            } else {
                dueLabel.text = "Due in \(Int(weeksRemaining)) weeks"
            }
            
        }
    
        if task!["member"] != nil {
            takeTaskButton.enabled = false
            if (task!["status"] as? String == "inProgress")
                || (task!["status"] as? String == "pending") {
                    takeTaskButton.setTitle("THIS TASK HAS BEEN TAKEN.", forState: .Disabled)
            } else if (task!["status"] as? String == "pending") {
                takeTaskButton.setTitle("TASK PENDING ACCEPTANCE.", forState: .Disabled)
            }
            getTaskOwner()
        } else {
            self.taskMemberLabel.text = "Nobody"
        }
        
        if task!["status"] as? String != "rejected" {
            commentsGreenLabel.hidden = true
            commentsLabel.hidden = true
        } else {
            commentsLabel.numberOfLines = 0
            commentsLabel.text = task!["rejection_message"] as? String
            commentsLabel.sizeToFit()
        }
        
        loadingView.addLoadingViewToView(self, loadingText: "Taking task...")
        loadingView.center.x = view.center.x - 20
        loadingView.center.y = view.center.y - 100
        loadingView.hidden = true
    }
    
    //MARK: Custom Functions
    
    func getTaskOwner() {
        let ownerReference = task!["member"] as! CKReference
        publicDatabase.fetchRecordWithID(ownerReference.recordID, completionHandler: { (owner, error) -> Void in
            if error != nil {
                checkError(error!, view: self)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.taskMemberLabel.text = "\(owner!["name"]!)"
            })
        })
    }
    
    
    func presentAlertController() {
        if currentMember!["current_tasks"] != nil && (currentMember!["current_tasks"] as! [CKReference]).count  > 0 {
            errorAlert("You already have a task!", message: "Either complete or abandon your current task before taking another.")
            
            
        } else {
            
            let alert = UIAlertController(title: "Take Task?", message: "Are you sure you want to take this task? Photos \(photoRequiredYesOrNo!).", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            let take = UIAlertAction(title: "Accept", style: .Default) { (UIAlertAction) -> Void in
                self.setReferences()
            }
            alert.addAction(cancel)
            alert.addAction(take)

            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func setReferences() {
        let taskRef = CKReference(record: task!, action: .None)
        if currentMember?.valueForKey("current_tasks") != nil {
            if (currentMember?.valueForKey("current_tasks") as! [CKReference]).count > 0 {
                let currentTasks = currentMember?.valueForKey("current_tasks")
                currentTasks?.insertObject(taskRef, atIndex: 0)
                currentMember?.setValue(currentTasks, forKey: "current_tasks")
            } else {
                let currentTasks = [taskRef]
                currentMember?.setValue(currentTasks, forKey: "current_tasks")
            }
        } else {
            let currentTasks = [taskRef]
            currentMember?.setValue(currentTasks, forKey: "current_tasks")
        }
        
        let memberRef = CKReference(record: currentMember!, action: .None)
        task?.setValue(memberRef, forKey: "member")
        task?.setValue("inProgress", forKey: "status")
        task?.setValue(NSDate.timeIntervalSinceReferenceDate(), forKey: "taskTaken")
        saveTaskAndMember([task!, currentMember!])
    }
    
    func saveTaskAndMember(recordsToSave: [CKRecord]) {
        loadingView.hidden = false
        let saveOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        saveOperation.atomic = true
        saveOperation.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                checkError(error!, view: self)
            } else {
                currentTask = self.task
                dispatch_async(dispatch_get_main_queue()) {
                        self.setDelegate()
                        self.loadingView.hidden = true
                        self.performSegueWithIdentifier("backHomeSegue", sender: self)
                }
            }
        }
        publicDatabase.addOperation(saveOperation)
    }
    
    func setDelegate () {
        if let delegate = self.delegate {
            delegate.claimTaskPressed(task)
        }
    }
    
    
    //MARK: Actions
    @IBAction func takeTaskButton(sender: UIButton) {
        presentAlertController() // --> setRefs --> save --> segue back home
    }
    
    //MARK: Delegate Functions
    
    //MARK: Segues
}
