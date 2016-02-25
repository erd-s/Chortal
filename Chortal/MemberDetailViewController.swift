//
//  MemberDetailViewController.swift
//  Chortal
//
//  Created by Kanybek Zhagusaev on 2/24/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class MemberDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var finishedTaskLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

   }
