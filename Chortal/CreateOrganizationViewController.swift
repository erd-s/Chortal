//
//  CreateOrganizationViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class CreateOrganizationViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    
    
    //MARK: Outlets
    
    @IBOutlet weak var organizationNameTextField: UITextField!
    @IBOutlet weak var adminNameTextField: UITextField!
    @IBOutlet weak var adminPasswordTextField: UITextField!
    @IBOutlet weak var organizationTypeTextField: UITextField!
    @IBOutlet var memberNameTextFields: [UITextField]!
    @IBOutlet var memberPasswordTextFields: [UITextField]!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Custom Functions
    
    //MARK: IBActions
    
    @IBAction func createOrganizationTap(sender: UIButton) {
    }
    //MARK: Delegate Functions
    
    //MARK: Segues
    
}
