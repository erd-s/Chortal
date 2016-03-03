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
    var memberArray = [CKRecord]()
    var adminRecordID: CKRecordID!
    var newTask: CKRecord!
    var taskReference: CKReference!
    var organizationReference: CKReference!
    var selectedMember: CKRecord!
    
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
        loadingAlert("Creating task...", viewController: self)
        
        memberSegmentedControl.setEnabled(false, forSegmentAtIndex: 0)
        memberSegmentedControl.setEnabled(false, forSegmentAtIndex: 1)
        datePicker.minimumDate = NSDate()
        fetchMembers()
    }
    
    override func viewDidAppear(animated: Bool) {
        datePicker.setDate(NSDate(timeIntervalSinceNow: 10800), animated: true)
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
        if incentiveTextField.text?.characters.count > 0 {
            newTask.setObject(incentiveTextField.text, forKey: "incentive")
        } else {
            newTask.setObject("None", forKey: "incentive")
        }
        if requirePhotoSwitch.on {
            newTask.setObject("true", forKey: "photo_required")
        } else {
            newTask.setObject("false", forKey: "photo_required")
        }
        assignReferences()
    }
    
    func assignReferences() {
        publicDatabase.fetchRecordWithID(currentOrg!.recordID) { (currentOrgUpdated, error) -> Void in
            if error != nil {
                checkError(error!, view: self)
            } else {
                currentOrg = currentOrgUpdated
                
                
                
                
                self.organizationReference = CKReference.init(recordID: currentOrg!.recordID, action: .None)
                self.taskReference = CKReference(recordID: self.newTask.recordID, action: .None)
                
                let arrayOfTaskRefs = NSMutableArray(object: self.taskReference)
                
                if currentOrg!.valueForKey("tasks") != nil {
                    arrayOfTaskRefs.addObjectsFromArray(currentOrg!.valueForKey("tasks") as! [AnyObject])
                    currentOrg!.setObject(arrayOfTaskRefs, forKey: "tasks")
                } else {
                    currentOrg!.setObject(arrayOfTaskRefs, forKey: "tasks")
                }
                
                if self.memberSegmentedControl.selected == true {
                    let memberReference = CKReference(record: self.selectedMember, action: .None)
                    let newCurrentTaskRef = NSMutableArray()
                    newCurrentTaskRef.addObject(self.taskReference)
                    if self.selectedMember["current_tasks"] != nil {
                        if (self.selectedMember["current_tasks"] as! [CKReference]).count != 0 {
                            newCurrentTaskRef.addObjectsFromArray(self.selectedMember["current_tasks"] as! [CKReference])
                        }
                    }
                    self.newTask.setObject(memberReference, forKey: "member")
                    self.newTask.setValue("inProgress", forKey: "statself.us")
                    self.selectedMember.setValue(newCurrentTaskRef, forKey: "current_tasks")
                    self.newTask.setValue(NSDate.timeIntervalSinceReferenceDate(), forKey: "taskTaken")
                    publicDatabase.saveRecord(self.selectedMember, completionHandler: { (member, error) -> Void in
                        if error != nil {
                            checkError(error!, view: self)
                        } else {
                            //do some good stuff
                        }
                    })
                } else {
                    self.newTask.setValue("unassigned", forKey: "status")
                }
                
                self.newTask.setObject(self.organizationReference, forKey: "organization")
                
                
                self.saveTaskAndOrganization([self.newTask, currentOrg!])
                
            }
        }
    }
    
    
    func saveTaskAndOrganization(records: [CKRecord]) {
        let saveRecordsOp = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        saveRecordsOp.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                checkError(error!, view: self)
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
    
    func fetchMembers(){
        var memberCount = 0
        
        if currentOrg?["members"] != nil {
            for member in currentOrg?["members"] as! [CKReference] {
                publicDatabase.fetchRecordWithID(member.recordID, completionHandler: { (memberRecord, error) -> Void in
                    if (error != nil) {
                        print("error fetching members: \(error)")
                    }
                    else {
                        self.memberArray.append(memberRecord!)
                        memberCount++
                        if memberCount == (currentOrg!["members"] as! [CKReference]).count {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.addMembersToSegmentedControl()
                            })
                        }
                    }
                })
            }
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func addMembersToSegmentedControl() {
        var x = 0
        memberSegmentedControl.removeAllSegments()
        for member in memberArray {
            memberSegmentedControl.insertSegmentWithTitle(member["name"] as? String, atIndex: x, animated: true)
            x++
        }
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
        memberSegmentedControl.selected = false
    }
    
    @IBAction func onSegmentedControlSelected(sender: AnyObject) {
        let segmentIndex = memberSegmentedControl.selectedSegmentIndex
        selectedMember = memberArray[segmentIndex]
        memberSegmentedControl.selected = true
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
