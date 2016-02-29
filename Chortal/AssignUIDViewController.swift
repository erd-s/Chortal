//
//  AssignUIDViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class AssignUIDViewController: UIViewController {
    //MARK: Properties
    var orgUID: String?

    
    //MARK: Outlets
    
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        uidLabel.text = orgUID
        uidLabel.sizeToFit()
    }
    
    //MARK: Custom Functions
    
    //MARK: IBActions
    @IBAction func onCopyButtonTap(sender: UIButton) {
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = "\(uidLabel!.text!)"
        uidLabel.text = "Copied!"
        uidLabel.textColor = .grayColor()
        uidLabel.sizeToFit()
    }
    
    //MARK: Delegate Functions
    
    //MARK: Segue

}
