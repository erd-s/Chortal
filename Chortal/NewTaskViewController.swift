//
//  NewTaskViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class NewTaskViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    var memberArray = [AnyObject]()
    var adminRecordID: CKRecordID!
    var newTask: CKRecord!
    var taskToOrgRef: CKReference!
    var orgToTaskRef: CKReference!
    
    //MARK: Outlets
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextField: UITextField!
    @IBOutlet weak var incentiveTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var memberSegmentedControl: UISegmentedControl!
    @IBOutlet weak var requirePhotoSwitch: UISwitch!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    //MARK: Custom Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func createNewTask() {
        newTask = CKRecord(recordType: "Task")
        newTask.setObject(datePicker.date, forKey: "due")
        newTask.setObject(taskDescriptionTextField.text, forKey: "description")
        newTask.setObject(taskNameTextField.text, forKey: "name")
        newTask.setObject(incentiveTextField.text, forKey: "incentive")
        if requirePhotoSwitch.on {
            newTask.setObject("true", forKey: "photo_required")
        } else {
            newTask.setObject("false", forKey: "photo_required")
        }
        
        
        assignReferences()
    }
    func assignReferences() {
        orgToTaskRef = CKReference.init(recordID: currentOrg!.recordID, action: .None)
        taskToOrgRef = CKReference(recordID: newTask.recordID, action: .None)

        let arrayOfTaskRefs = NSMutableArray(object: taskToOrgRef)
        
        if currentOrg!.valueForKey("tasks") != nil {
            arrayOfTaskRefs.addObjectsFromArray(currentOrg!.valueForKey("tasks") as! [AnyObject])
            currentOrg!.setObject(arrayOfTaskRefs, forKey: "tasks")
        } else {
            currentOrg!.setObject(arrayOfTaskRefs, forKey: "tasks")
        }
        newTask.setObject(orgToTaskRef, forKey: "organization")
        newTask.setValue("unassigned", forKey: "status")
        
        saveTaskAndOrganization([newTask, currentOrg!])
    }
    
    func saveTaskAndOrganization(records: [CKRecord]) {
        let saveRecordsOp = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        saveRecordsOp.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                print(error)
            } else {
                print("saved task")
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.performSegueWithIdentifier("unwindFromTaskCreate", sender: self)
                    })
                }
            }
        }
        publicDatabase.addOperation(saveRecordsOp)
    }
    
    //MARK: IBActions
    @IBAction func createTaskButtonTap(sender: AnyObject) {
        if taskNameTextField.text?.characters.count > 0 {
            loadingAlert("Saving task...", viewController: self)
            createNewTask()
        } else {
            let alert = UIAlertController(title: "Error", message: "Please enter a task name.", preferredStyle: .Alert)
            let okay = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(okay)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func clearSegmentedControlButtonTap(sender: UIButton) {
        memberSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindFromTaskCreate" {
            let vc = segue.destinationViewController as! AdminHomeViewController
            vc.taskArray.append(newTask)
        }
    }
    
}
