//
//  AdminSettingsViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/22/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class AdminSettingsViewController: UIViewController {
    //MARK: Properties
    
    
    //MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var inviteCodeLabel: UILabel!
    @IBOutlet weak var organizationNameTextField: UITextField!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        nameTextField.text = userDefaults.stringForKey("adminName")!
        organizationNameTextField.text = currentOrg!["name"] as? String
        inviteCodeLabel.text = orgUID
    }
    
    //MARK: Custom Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: Actions
    @IBAction func saveButtonTap(sender: AnyObject) {
        loadingAlert("Saving settings...", viewController: self)
        
        userDefaults.setValue(nameTextField.text, forKey: "adminName")
        
        if organizationNameTextField.text != currentOrg!["name"] as? String {
            userDefaults.setValue(organizationNameTextField.text, forKey: "currentOrgName")
            currentOrg?.setValue(organizationNameTextField.text, forKey: "name")
            publicDatabase.saveRecord(currentOrg!, completionHandler: { (currentOrg, error) -> Void in
                if error != nil {
                    print("error saving organization name: \(error)")
//----------------->sometimes has an error saving the organization
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            UtilityFile.instantiateToAdminHome(self)

                         //   self.performSegueWithIdentifier("saveAdminSettingsSegue", sender: self)
                        })
                    
                    })
                }
            })
        } else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                UtilityFile.instantiateToAdminHome(self)

//                self.performSegueWithIdentifier("saveAdminSettingsSegue", sender: self)
            })
        }
    }

    @IBAction func copyInviteCode(sender: AnyObject) {
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = "\(orgUID!)"
        inviteCodeLabel.text = "Copied!"
    }
    
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segues
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
