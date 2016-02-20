//
//  TakeTaskViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/20/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class TakeTaskViewController: UIViewController {
    //MARK: Properties
    var task: CKRecord?
    var photoRequiredYesOrNo: String?
    var currentMember: CKRecord?
    var organization: CKRecord?
    var dueDate: NSDate?
    
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
        
        dueDate = task!["due"] as? NSDate
        
        if task!["photo_required"] as? String == "yes" {
            photoRequiredYesOrNo = "are required."
        } else {
            photoRequiredYesOrNo = "are not required"
        }
        
        photoRequiredLabel.text = "Photos \(photoRequiredYesOrNo)."
        taskDescriptionLabel.text = task!["description"] as? String
        taskNameLabel.text = task!["name"] as? String
        dueLabel.text = String(dueDate!)
        taskMemberLabel.text = task!["member"] as? String
        fetchCurrentMember(userDefaults.valueForKey("currentUserName") as! String)
    }
    
    //MARK: Custom Functions
    func fetchCurrentMember(memberName: String) {
        for ref in organization!["members"] as! [CKReference] {
            publicDatabase.fetchRecordWithID(ref.recordID, completionHandler: { (member, error) -> Void in
                if member!["name"] as? String == memberName {
                    self.currentMember = member
                    self.takeTaskButton.userInteractionEnabled = true
                    self.takeTaskButton.enabled = true
                }
            })
        }
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
        currentMember?.setValue(taskRef, forKey: "current_task")
        
        let memberRef = CKReference(record: currentMember!, action: .None)
        task?.setValue(memberRef, forKey: "member")
        
        saveTaskAndMember([task!, currentMember!])
    }
    
    func saveTaskAndMember(recordsToSave: [CKRecord]) {
        let saveOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        saveOperation.atomic = true
        saveOperation.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                print(error)
            } else {
                print("saved records successfully")
                //start timer
                self.performSegueWithIdentifier("backHomeSegue", sender: self)
            }
        }
        publicDatabase.addOperation(saveOperation)
    }
    
    
    //MARK: Actions
    @IBAction func takeTaskButton(sender: UIButton) {
        presentAlertController() // --> setRefs --> save --> segue back home
    }
    
    //MARK: Delegate Functions
    
    //MARK: Segues
}
