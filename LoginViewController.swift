//
//  LoginViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    
    
    //MARK: Outlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Custom Functions

    //MARK: IBActions
    @IBAction func loginButtonTap(sender: AnyObject) {
    }
    
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    //MARK: Segues
    
}
