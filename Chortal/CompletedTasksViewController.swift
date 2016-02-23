//
//  CompletedTasksViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/23/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class CompletedTasksViewController: UIViewController, UIScrollViewDelegate {
    //MARK: Properties
    var completedTaskArray = [CKRecord]()
    var currentIndex = 0
    var currentCompletedTask: CKRecord!
    
    //MARK: Outlets
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var incentiveLabel: UILabel!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Custom Functions
    func fetchCompletedRecords() {
        for ref in currentOrg!["tasks"] as! [CKReference] {
            publicDatabase.fetchRecordWithID(ref.recordID, completionHandler: { (taskRecord, error) -> Void in
                if error != nil {
                    print("there was an error retrieving completed tasks. \(error)")
                } else {
                    if taskRecord!["inProgress"] as? String == "true" && taskRecord!["completed"] as? String == "true" {
                        self.completedTaskArray.append(taskRecord!)
                    }
                }
            })
        }
    }
    
    func layOutDataForCompletedRecord(index: Int) {
        currentCompletedTask = completedTaskArray[index]
        taskNameLabel.text = currentCompletedTask["name"] as? String
        incentiveLabel.text = currentCompletedTask["incentive"] as? String
        memberNameLabel.text = currentCompletedTask["member_name"] as? String
        taskDescriptionLabel.text = currentCompletedTask["description"] as? String
        var x = 0
        
        for photoAsset in (currentCompletedTask["photos"] as? [CKAsset])! {
            let photo = UIImage(data: NSData(contentsOfURL: photoAsset.fileURL)!)
            addPhotoToScrollView(photo!, position: x)
            x = x + 1
        }
        
        currentIndex = currentIndex + 1
    }
    
    func addPhotoToScrollView(photo: UIImage, position: Int) {
        let x = Int(scrollView.frame.origin.x) + (position * Int(scrollView.frame.origin.x))
        let imageView = UIImageView(frame: CGRect(x: CGFloat(x), y: scrollView.frame.origin.y, width: scrollView.frame.width, height: scrollView.frame.height))
        imageView.image = photo
        scrollView.addSubview(imageView)
    }
    
    func presentRejectionAlertController() {
        let rejectionAlertController = UIAlertController(title: "Reject task?", message: "Please add a message.", preferredStyle: .Alert)
        rejectionAlertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Reason why task is rejected."
        }
        
        let textField = rejectionAlertController.textFields?.first
        
        let rejectAction = UIAlertAction(title: "Reject Task", style: .Destructive) { (action) -> Void in
            while textField!.text == "" {
                action.enabled = false
            }
            self.currentCompletedTask!.setValue("false", forKey: "completed")
            self.currentCompletedTask!.setValue("true", forKey: "inProgress")
            self.currentCompletedTask.setValue(textField?.text, forKey: "rejection_message")
            
            //--> send push notification
            self.layOutDataForCompletedRecord(self.currentIndex)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        rejectionAlertController.addAction(rejectAction)
        rejectionAlertController.addAction(cancelAction)
        
        presentViewController(rejectionAlertController, animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func rejectActionTap(sender: UIButton) {
        presentRejectionAlertController()
    }
    
    @IBAction func acceptActionTap(sender: UIButton) {
        //--> do some stuff
        
        layOutDataForCompletedRecord(currentIndex)
    }
    
    @IBAction func skipActionTap(sender: UIButton) {
        layOutDataForCompletedRecord(currentIndex)
    }
    //MARK: Delegate Functions
    
    //MARK: Segues
}
