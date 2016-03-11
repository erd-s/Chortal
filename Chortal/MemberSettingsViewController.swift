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
    let loadingView = LoadingView()
    
    
    //MARK: Outlets
    @IBOutlet weak var multipleUsersSwitch: UISwitch!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var defaultPhotoImageView: UIImageView!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        loadingView.addLoadingViewToView(self, loadingText: "Saving settings...")
        loadingView.hidden = true
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
                self.saveImageLocally()
            }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImageLocally () {
        let path = NSTemporaryDirectory().stringByAppendingString("profile_picture.tmp")
        let data = UIImageJPEGRepresentation(defaultPhotoImageView!.image!, 0.7)
        data!.writeToFile(path, atomically: true)
        
        self.imageAsset = CKAsset(fileURL: NSURL(fileURLWithPath: path))
    }
    
    @IBAction func undoButtonTapped(sender: UIBarButtonItem) {
        UtilityFile.instantiateToMemberHome(self)
    }
    
    
    @IBAction func saveButtonTap(sender: AnyObject) {
        loadingView.hidden = false
        currentMember!.setObject(imageAsset, forKey: "profile_picture")
        
        if multipleUsersSwitch.on    { userDefaults.setBool(true, forKey: "multipleUsers") }
        else { userDefaults.setBool(false, forKey: "multipleUsers") }
        
        if (nameTextField.text != memberName) || (currentMember!["profile_photo"] as? CKAsset != imageAsset) {
            
            userDefaults.setValue(nameTextField.text, forKey: "currentUserName")
            currentMember?.setValue(nameTextField.text, forKey: "name")
            publicDatabase.saveRecord(currentMember!, completionHandler: { (memberSaved, error) -> Void in
                if error != nil {
                    checkError(error!, view: self)
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.loadingView.hidden = true
                        UtilityFile.instantiateToMemberHome(self)
                    })
                }
            })
        } else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.loadingView.hidden = true
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
