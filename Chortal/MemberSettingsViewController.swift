//
//  MemberSettingsViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/22/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class MemberSettingsViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    var imageAsset:CKAsset?
    
    
    //MARK: Outlets
    @IBOutlet weak var multipleUsersSwitch: UISwitch!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var defaultPhotoImageView: UIImageView!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if userDefaults.boolForKey("multipleUsers") {
            multipleUsersSwitch.setOn(true, animated: true)
        } else {
            multipleUsersSwitch.setOn(false, animated: true)
        }
        
        nameTextField.text = userDefaults.valueForKey("currentUserName") as? String
        
        imageAsset = currentMember?["profile_picture"] as? CKAsset
        defaultPhotoImageView.image = UIImage(data: NSData(contentsOfURL: (imageAsset?.fileURL)!)!)
    }
    
    //MARK: Custom Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: Actions
    @IBAction func changePhotoButtonTap(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true;
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func addPhotoButtonTap(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true;
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
        [String : AnyObject]) {
            let imageToSave = info[UIImagePickerControllerEditedImage] as? UIImage
            picker.dismissViewControllerAnimated(true) { () -> Void in
                self.defaultPhotoImageView.image = imageToSave
                self.defaultPhotoImageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.saveImageLocaly()
            }
            
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func saveImageLocaly () {
        let data = UIImagePNGRepresentation(defaultPhotoImageView.image!)
        let filename = getDocumentsDirectory().stringByAppendingPathComponent("profile_picture.png")
        data!.writeToFile(filename, atomically: true)
        self.imageAsset = CKAsset(fileURL: NSURL(fileURLWithPath: filename))
        
    }

    
    @IBAction func undoButtonTapped(sender: UIBarButtonItem) {
        UtilityFile.instantiateToMemberHome(self)
    }
    
    
    @IBAction func saveButtonTap(sender: AnyObject) {
        loadingAlert("Saving settings...", viewController: self)
        currentMember!.setObject(imageAsset, forKey: "profile_picture")

        if multipleUsersSwitch.on    { userDefaults.setBool(true, forKey: "multipleUsers") }
        else { userDefaults.setBool(false, forKey: "multipleUsers") }
        
        if (nameTextField.text != memberName) || (currentMember!["profile_photo"] as? CKAsset != imageAsset) {

            userDefaults.setValue(nameTextField.text, forKey: "currentUserName")
            currentMember?.setValue(nameTextField.text, forKey: "name")
            publicDatabase.saveRecord(currentMember!, completionHandler: { (memberSaved, error) -> Void in
                if error != nil {
                    print("name not saved, error:\(error)")
                } else {
                    print("saved new username successfully")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            UtilityFile.instantiateToMemberHome(self)
                        })
                    })
                }
            })
        } else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
            UtilityFile.instantiateToMemberHome(self)
            })
        }
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segues
    
}
