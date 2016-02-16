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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var organizationNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Custom Functions
    @IBAction func forgotInfoButtonTap(sender: AnyObject) {
        
    }
    
    @IBAction func loginButtonTap(sender: UIButton) {
    }

    //MARK: IBActions
    
    //MARK: Delegate Functions
    
    //MARK: Segues
    
}
