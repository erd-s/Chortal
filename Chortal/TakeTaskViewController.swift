//
//  TakeTaskViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/20/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class TakeTaskViewController: UIViewController {
    //MARK: Properties
    var task: CKRecord?
    var photoRequiredYesOrNo: String?
    
    //MARK: Outlets
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var photoRequiredLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let date = task!["due"] as? NSDate
        
        if task!["photo_required"] as? String == "yes" {
            photoRequiredYesOrNo = "are required."
        } else {
            photoRequiredYesOrNo = "are not required"
        }
        
        photoRequiredLabel.text = "Photos \(photoRequiredYesOrNo)."
        taskDescriptionLabel.text = task!["description"] as? String
        taskNameLabel.text = task!["name"] as? String
        dueLabel.text = String(date!)
    }

    //MARK: Custom Functions
    func presentAlertController() {
        let dueDate = ""
        let requiredYesOrNo = ""
        let alert = UIAlertController(title: "Take Task?", message: "This task is due: \(dueDate). Photos \(requiredYesOrNo).", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let take = UIAlertAction(title: "Take Task", style: .Default) { (UIAlertAction) -> Void in
            self.assignTaskToSelf()
        }
        
        
        alert.addAction(cancel)
        alert.addAction(take)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func assignTaskToSelf() {
        
    }
    
    
    
    //MARK: Actions
    @IBAction func takeTaskButton(sender: UIButton) {
        
        
        
        
        
    }
    
    //MARK: Delegate Functions
    
    //MARK: Segues
}
