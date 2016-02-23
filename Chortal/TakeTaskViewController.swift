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
    var organization: CKRecord?
    var dueDate: NSDate?
    var delegate: ClaimTaskDelegate?
    
    //MARK: Outlets
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var photoRequiredLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var takeTaskButton: UIButton!
    @IBOutlet weak var taskMemberLabel: UILabel!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dueDate = task?["due"] as? NSDate
        
        if task?["photo_required"] as? String == "yes" {
            photoRequiredYesOrNo = "are required."
        } else {
            photoRequiredYesOrNo = "are not required"
        }
        
        photoRequiredLabel.text = "Photos \(photoRequiredYesOrNo!)."
        taskDescriptionLabel.text = task!["description"] as? String
        taskNameLabel.text = task!["name"] as? String
        dueLabel.text = String(dueDate!)
        self.taskMemberLabel.text = "Claimed By:"
        if task!["member"] != nil {
            takeTaskButton.enabled = false
            getTaskOwner()
            //taskMemberLabel.text = "\(task!["member"] as! CKReference)"
        } else {
            self.taskMemberLabel.text = "Claimed By: No One!"
        }
    }
    
    //MARK: Custom Functions
    
    func getTaskOwner() {
        let ownerReference = task!["member"] as! CKReference
        publicDatabase.fetchRecordWithID(ownerReference.recordID, completionHandler: { (task, error) -> Void in
            if error != nil {
                print(error)
            } else {
                
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.taskMemberLabel.text = "Claimed By: \(task!["name"]!)"
            })
        })
    }
    
    
    func presentAlertController() {
        let alert = UIAlertController(title: "Take Task?", message: "This task is due: \(String(dueDate!)). Photos \(photoRequiredYesOrNo). The timer will start when you click \"Accept\".", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let take = UIAlertAction(title: "Accept", style: .Default) { (UIAlertAction) -> Void in
            self.setReferences()
        }
        alert.addAction(cancel)
        alert.addAction(take)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func setReferences() {
        let taskRef = CKReference(record: task!, action: .None)
        currentUser?.setValue(taskRef, forKey: "current_task")
        
        let memberRef = CKReference(record: currentUser!, action: .None)
        task?.setValue(memberRef, forKey: "member")
        task?.setValue("true", forKey: "inProgress")
        saveTaskAndMember([task!, currentUser!])
    }
    
    func saveTaskAndMember(recordsToSave: [CKRecord]) {
        loadingAlert("Taking task...", viewController: self)
        let saveOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        saveOperation.atomic = true
        saveOperation.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                print(error)
            } else {
                print("saved records successfully")
                //start timer
                currentTask = self.task
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.setDelegate()
                        self.performSegueWithIdentifier("backHomeSegue", sender: self)
                    })
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
