//
//  CreateOrJoinViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/27/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class CreateOrJoinViewController: UIViewController {
    
    @IBOutlet weak var createGroupButton: CHNBootstrapButton!
    @IBOutlet weak var joinGroupButton: CHNBootstrapButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGroupButton.chnButtonStyle = .Success
        joinGroupButton.chnButtonStyle = .Success
        createGroupButton.setTitleColor(.whiteColor(), forState: .Normal)
        joinGroupButton.setTitleColor(.whiteColor(), forState: .Normal)
        
        
        
        
    }
}
