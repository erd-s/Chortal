//
//  CompletedTasksViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/23/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class CompletedTasksViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    //MARK: Properties
    var completedTaskArray = [CKRecord]()
    var currentIndex = 0
    var currentCompletedTask: CKRecord!
    var pressLocation: CGPoint?
    
    //MARK: Outlets
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var incentiveLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        fetchCompletedTasks()
        
    }
    
    //MARK: Custom Functions
    func fetchCompletedTasks() {
        var layedOutData = false
        
        if currentOrg!["tasks"] != nil {
            if (currentOrg!["tasks"] as! [CKReference]).count > 0 {
                for taskReference in currentOrg!["tasks"] as![CKReference] {
                    publicDatabase.fetchRecordWithID(taskReference.recordID, completionHandler: { (fetchedTask, error) -> Void in
                        if error != nil {
                            print("error fetching tasks: \(error)")
                        }
                        if fetchedTask!["status"] as? String == "pending" {
                            self.completedTaskArray.append(fetchedTask!)
                            if layedOutData == false {
                                layedOutData = true
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.setDisplayedTask(self.currentIndex)
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    
    func finishAndExit() {
        let alertController = UIAlertController(title: "No more completed tasks.", message: nil, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default) { (UIAlertAction) -> Void in
            self.performSegueWithIdentifier("unwindToSidebar", sender: self)
        }
        
        alertController.addAction(ok)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // take task 1, display it, when it gets rejected or accepted, go to the next task and start over.
    // finish when an index reaches the count of the total number of tasks.
    
    func setDisplayedTask(index: Int){
        if index == 0 {
            currentCompletedTask = completedTaskArray[0]
        } else if index == completedTaskArray.count {
            finishAndExit()
        }
        else {
            currentCompletedTask = completedTaskArray[index]
        }
        
        layoutData()
    }
    
    func layoutData() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.taskNameLabel.text = self.currentCompletedTask["name"] as? String
            
            let timeTakenInSeconds = self.currentCompletedTask["taskCompletedTime"] as? Double
            if timeTakenInSeconds < 60 {
                self.timeTakenLabel.text = "\(Int(timeTakenInSeconds!))s"
            } else if timeTakenInSeconds < 3600 {
                let timeTakenInMinutes = Int(timeTakenInSeconds! / 60)
                self.timeTakenLabel.text = "\(timeTakenInMinutes)m"
            } else if timeTakenInSeconds < 86400 {
                let timeTakenInHours = Int(timeTakenInSeconds! / 3600)
                self.timeTakenLabel.text = "\(timeTakenInHours)h"
            } else {
                let timeTakenInDays = Int(timeTakenInSeconds! / 86400)
                self.timeTakenLabel.text = "\(timeTakenInDays)d"
            }
            
            if self.currentCompletedTask["description"] as? String == "" {
                self.taskDescriptionLabel.text = "No description."
            } else {
                self.taskDescriptionLabel.text = self.currentCompletedTask["description"] as? String
            }
            
            if self.currentCompletedTask["incentive"] as? String == "" {
                self.incentiveLabel.text = "No incentive."
            } else {
                self.incentiveLabel.text = self.currentCompletedTask["incentive"] as? String
            }
        }
        var x = CGFloat(0)
        for imageAsset in currentCompletedTask["photos"] as! [CKAsset] {
            let image = UIImage(data: NSData(contentsOfURL: imageAsset.fileURL)!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.addPhotoToScrollView(image!, position: x)
                x++
            })
        }
    }
    
    func addPhotoToScrollView(photo: UIImage, position: CGFloat) {
        let x = scrollView.contentOffset.x + (position * scrollView.frame.width)
        let imageView = UIImageView(frame: CGRect(x: x, y: scrollView.contentOffset.y, width: scrollView.frame.width, height: scrollView.frame.height))
        imageView.image = photo
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 1
        imageView.userInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressHandler:")
        longPress.delegate = self
        imageView.addGestureRecognizer(longPress)
        
        scrollView.contentSize.width = (scrollView.frame.width + (position * scrollView.frame.width))
        scrollView.addSubview(imageView)
    }
    
    func presentRejectionAlertController() {
        let rejectionAlertController = UIAlertController(title: "Reject task?", message: "Please add a message.", preferredStyle: .Alert)
        rejectionAlertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "e.g. Not clean enough."
        }
        
        let textField = rejectionAlertController.textFields?.first
        
        let rejectAction = UIAlertAction(title: "Reject Task", style: .Destructive) { (action) -> Void in
            self.currentCompletedTask!.setValue("rejected", forKey: "status")
            self.currentCompletedTask.setValue(textField?.text, forKey: "rejection_message")
            
            self.loadingAlert("Task complete...", viewController: self)
            publicDatabase.saveRecord(self.currentCompletedTask) { (currentTask, error) -> Void in
                if error != nil {
                    print("error marking task as completed: \(error))")
                } else {
                    print("sucesssfully saved task")
                    self.currentIndex++
                    self.setDisplayedTask(self.currentIndex)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        rejectionAlertController.addAction(rejectAction)
        rejectionAlertController.addAction(cancelAction)
        
        presentViewController(rejectionAlertController, animated: true, completion: nil)
    }
    
    func longPressHandler(longPress: UIGestureRecognizer) {
        let state = longPress.state
        
        let rejectPhotoAlert = UIAlertController(title: "Would you like to hide photo?", message: nil, preferredStyle: .ActionSheet)
        let reject = UIAlertAction(title: "Hide", style: .Destructive) { (UIAlertAction) -> Void in
            var index = 0
            for subview in self.scrollView.subviews {
                print("subview: \(subview), pressLocation: \(self.pressLocation)")
                if subview.frame.contains(self.pressLocation!) {
                    self.scrollView.subviews[index].hidden = true
                    index++
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        rejectPhotoAlert.addAction(reject)
        rejectPhotoAlert.addAction(cancel)
        
        if state == .Began {
            pressLocation = longPress.locationInView(self.scrollView)
            presentViewController(rejectPhotoAlert, animated: true, completion: nil)
        }
        
    }
    
    //MARK: Actions
    @IBAction func rejectActionTap(sender: UIButton) {
        presentRejectionAlertController()
    }
    
    @IBAction func acceptActionTap(sender: UIButton) {
        currentCompletedTask.setValue("completed", forKey: "status")
        publicDatabase.saveRecord(currentCompletedTask) { (currentTask, error) -> Void in
            if error != nil {
                print("error marking task as completed: \(error))")
            } else {
                print("sucesssfully saved task")
                self.currentIndex++
                self.setDisplayedTask(self.currentIndex)
            }
        }
    }
    //MARK: Delegate Functions
    
    //MARK: Segues
}
