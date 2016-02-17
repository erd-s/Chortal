//
//  NewTaskViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    
    
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
    }
    
    //MARK: Custom Functions
    
    
    //MARK: IBActions
    @IBAction func createTaskButtonTap(sender: AnyObject) {

        if requirePhotoSwitch.selected {
            //require a photo
        }
    }

    @IBAction func clearSegmentedControlButtonTap(sender: UIButton) {
        memberSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    //MARK: Delegate Functions
    
    //MARK: Segue
    
    
}
