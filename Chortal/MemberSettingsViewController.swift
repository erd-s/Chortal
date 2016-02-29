//
//  MemberSettingsViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/22/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class MemberSettingsViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    
    
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
        
        defaultPhotoImageView.image = currentMember?["photo"] as? UIImage
    }
    
    //MARK: Custom Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: Actions
    @IBAction func changePhotoButtonTap(sender: AnyObject) {
        //open image picker
    }
    
    @IBAction func saveButtonTap(sender: AnyObject) {
        loadingAlert("Saving settings...", viewController: self)
        if multipleUsersSwitch.on    { userDefaults.setBool(true, forKey: "multipleUsers") }
        else { userDefaults.setBool(false, forKey: "multipleUsers") }
        
        if nameTextField.text != memberName {
            userDefaults.setValue(nameTextField.text, forKey: "currentUserName")
            currentMember?.setValue(nameTextField.text, forKey: "name")
            publicDatabase.saveRecord(currentMember!, completionHandler: { (memberSaved, error) -> Void in
                if error != nil {
                    print("name not saved, error:\(error)")
                } else {
                    print("saved new username successfully")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.performSegueWithIdentifier("saveSettingsSegue", sender: self)
                        })
                    })
                }
            })
        } else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.performSegueWithIdentifier("saveSettingsSegue", sender: self)
            })
        }
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segues
    
}
