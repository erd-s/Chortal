//
//  WelcomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class WelcomeViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    var orgRecord: CKRecord?
    var newMember: CKRecord?
    var memberRef: CKReference?
    var orgRef: CKReference?
    var memberArray = [] as NSMutableArray
    var seguedFromMemberSelect: Bool?
    var imageAsset: CKAsset?
    
    
    
    //MARK: Outlets
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var multipleUsersSwitch: UISwitch!
    @IBOutlet weak var multipleUsersLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        multipleUsersSwitch.selected = true
    }
    
    override func viewWillAppear(animated: Bool) {
        welcomeLabel.text = "Welcome to \(orgRecord!.valueForKey("name")!)"
        
        if seguedFromMemberSelect == true {
            multipleUsersLabel.hidden = true
            multipleUsersSwitch.hidden = true
        }
    }
    
    //MARK: Custom Functions
    func setPushSettings() {
        userDefaults.setBool(true, forKey: "push_taskApproved")
        userDefaults.setBool(true, forKey: "push_taskDenied")
        userDefaults.setBool(true, forKey: "push_timeRunningOut")
        userDefaults.setBool(true, forKey: "push_newTasks")
        userDefaults.setBool(true, forKey: "push_taskAssigned")
    }
    
    func uniqueMemberNameCheck() {
        if orgRecord?.mutableArrayValueForKey("members").count == 0 {
            createMember()
        } else {
            for memberReference in (orgRecord?.mutableArrayValueForKey("members"))! {
                publicDatabase.fetchRecordWithID(memberReference.recordID, completionHandler: { (resultRecord, error) -> Void in
                    
                    if error != nil {
                        checkError(error!, view: self)
                    } else {
                        
                        if resultRecord!["name"] as? String == self.nameTextField.text {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                    self.errorAlert("Error", message: "A member of \(self.orgRecord!["name"]!) already has that name. Please choose another.")
                                })
                            }
                        } else {
                            self.createMember()
                        }
                    }
                })
            }
        }
        
    }
    
    func createMember() {
        if newMember == nil {
            newMember = CKRecord(recordType: "Member")
            newMember!.setValue(nameTextField.text, forKey: "name")
            
            orgRef = CKReference(recordID: orgRecord!.recordID, action: .None)
            newMember!.setValue(orgRef, forKey: "organization")
            newMember!.setObject(imageAsset, forKey: "profile_picture")
            
            memberRef = CKReference(recordID: newMember!.recordID, action: .None)
            
            setReferencesForOrg()
        }
    }
    
    func setReferencesForOrg() {
        if orgRecord!.mutableArrayValueForKey("members").count == 0 {
            memberArray = [memberRef!]
            orgRecord?.setObject(memberArray, forKey: "members")
            modifyRecords([orgRecord!, newMember!])
        } else {
            memberArray =
                orgRecord!.mutableArrayValueForKey("members")
            memberArray.addObject(memberRef!)
            //                orgRecord?.setObject(memberArray, forKey: "members")
            modifyRecords([orgRecord!, newMember!])
        }
    }
    
    func modifyRecords (records: [CKRecord]) {
        print("Modify records function called")
        let saveRecordsOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        
        saveRecordsOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                checkError(error!, view: self)
            }else {
                print("Successfully saved")
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.performSegueWithIdentifier("logInSegue", sender: self)
                })
            }
        }
        publicDatabase.addOperation(saveRecordsOperation)
    }
    
    //MARK: IBActions
    @IBAction func logInButtonTapped(sender: UIButton) {
        if nameTextField.text?.characters.count > 0 {
            if imageAsset != nil {
                loadingAlert("Loading...", viewController: self)
                uniqueMemberNameCheck()
            } else {
                errorAlert("Error", message: "Please enter your name and add a picture.")
            }
            //            createMember()
        } else {
            errorAlert("Error", message: "Please enter your name and add a picture.")
            
        }
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logInSegue" {
            let userName = newMember?.valueForKey("name")
            userDefaults.setValue(userName, forKey: "currentUserName")
            
            if multipleUsersSwitch == true {
                userDefaults.setBool(false, forKey: "multipleUsers")
            } else {
                userDefaults.setBool(true, forKey: "multipleUsers")
                
            }
            let currentOrgUID = orgRecord?.valueForKey("uid")
            userDefaults.setValue(currentOrgUID, forKey: "currentOrgUID")
            userDefaults.setValue(orgRecord?.valueForKey("name"), forKey: "currentOrgName")
        }
        
    }
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true;
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func getPhotoFromLibrary(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true;
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        saveImageLocaly()
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
//    func getDocumentsDirectory() -> NSString {
//        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }
    
    func saveImageLocaly () {
        let path = NSTemporaryDirectory().stringByAppendingString("profile_picture.tmp")
        let data = UIImageJPEGRepresentation(imageView!.image!, 0.7)
        data!.writeToFile(path, atomically: true)
        
        self.imageAsset = CKAsset(fileURL: NSURL(fileURLWithPath: path))
        
    }
    
    
    
    
}









