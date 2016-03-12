//
//  ChortalHomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/27/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class ChortalHomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        isICloudContainerAvailable()
    }
}
