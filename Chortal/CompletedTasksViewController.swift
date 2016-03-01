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
    var layoutTriggeredAtLeastOnce = false
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
        fetchCompletedRecords()
        loadingAlert("Loading tasks...", viewController: self)
        
    }
    
    //MARK: Custom Functions
    func fetchCompletedRecords() {
        if currentOrg!["tasks"] != nil {
            for ref in currentOrg!["tasks"] as! [CKReference] {
                publicDatabase.fetchRecordWithID(ref.recordID, completionHandler: { (taskRecord, error) -> Void in
                    if error != nil {
                        print("there was an error retrieving completed tasks. \(error)")
                    } else {
                        if taskRecord!["status"] as? String == "pending" {
                            self.completedTaskArray.append(taskRecord!)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                    self.layOutDataForCompletedRecord()
                                })
                            })
                        } else {
                            if ref == (currentOrg!["tasks"] as! [CKReference]).last {
                                if taskRecord!["status"] as? String != "pending" {
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                            self.presentNoCompletedTasksAlertController("No completed tasks.")
                                        })
                                    })
                                }
                            }
                        }
                    }
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.presentNoCompletedTasksAlertController("Please assign a task first.")
                })
            })
        }
    }
    
    func layOutDataForCompletedRecord() {
        if completedTaskArray.count > currentIndex {
            currentCompletedTask = completedTaskArray[currentIndex]
            taskNameLabel.text = currentCompletedTask["name"] as? String
            incentiveLabel.text = currentCompletedTask["incentive"] as? String
            taskDescriptionLabel.text = currentCompletedTask["description"] as? String
            taskDescriptionLabel.numberOfLines = 0
            taskDescriptionLabel.sizeToFit()
            let timeTakenInSeconds = currentCompletedTask["taskCompletedTime"] as? Double
            
            
            if timeTakenInSeconds < 60 {
                timeTakenLabel.text = "\(Int(timeTakenInSeconds!))s"
            } else if timeTakenInSeconds < 3600 {
                let timeTakenInMinutes = Int(timeTakenInSeconds! / 60)
                timeTakenLabel.text = "\(timeTakenInMinutes))m"
            } else if timeTakenInSeconds < 86400 {
                let timeTakenInHours = Int(timeTakenInSeconds! / 3600)
                timeTakenLabel.text = "\(timeTakenInHours))h"
            } else {
                let timeTakenInDays = Int(timeTakenInSeconds! / 86400)
                timeTakenLabel.text = "\(timeTakenInDays))d"
            }
            
            var x = 0
            
            for photoAsset in (currentCompletedTask["photos"] as? [CKAsset])! {
                let photo = UIImage(data: NSData(contentsOfURL: photoAsset.fileURL)!)
                addPhotoToScrollView(photo!, position: CGFloat(x))
                x = x + 1
            }
            layoutTriggeredAtLeastOnce = true
            currentIndex = currentIndex + 1
        } else {
            if layoutTriggeredAtLeastOnce == true {
                presentNoCompletedTasksAlertController("No more completed tasks.")
            }
            presentNoCompletedTasksAlertController("No completed tasks.")
        }
    }
    
    func addPhotoToScrollView(photo: UIImage, position: CGFloat) {
        let x = scrollView.contentOffset.x + (position * scrollView.frame.width)
        let imageView = UIImageView(frame: CGRect(x: x, y: scrollView.contentOffset.y, width: scrollView.frame.width, height: scrollView.frame.height))
        imageView.image = photo
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 1
        imageView.userInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPressHandler")
        longPress.delegate = self
        imageView.addGestureRecognizer(longPress)
        
        scrollView.contentSize.width = (scrollView.frame.width + (position * scrollView.frame.width))
        scrollView.addSubview(imageView)
    }
    
    func longPressHandler(longPress: UIGestureRecognizer) {
        let state = longPress.state

        let rejectPhotoAlert = UIAlertController(title: "Would you like to hide photo?", message: nil, preferredStyle: .ActionSheet)
        let reject = UIAlertAction(title: "Hide", style: .Destructive) { (UIAlertAction) -> Void in
            var index = 0
            for subview in self.scrollView.subviews {
                if subview.frame.contains(self.pressLocation!) {
                    self.scrollView.subviews[index].hidden = true
                    index++
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        rejectPhotoAlert.addAction(reject)
        rejectPhotoAlert.addAction(cancel)
        
        if state == .Ended {
            pressLocation = longPress.locationInView(self.scrollView)
            presentViewController(rejectPhotoAlert, animated: true, completion: nil)
        }

    }
    
    func presentNoCompletedTasksAlertController(title: String) {
        let noTasksAlertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier("unwindToSidebar", sender: self)
        }
        noTasksAlertController.addAction(okAction)
        presentViewController(noTasksAlertController, animated: true, completion: nil)
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
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.layOutDataForCompletedRecord()
                    })
                })
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        rejectionAlertController.addAction(rejectAction)
        rejectionAlertController.addAction(cancelAction)
        
        presentViewController(rejectionAlertController, animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func rejectActionTap(sender: UIButton) {
        presentRejectionAlertController()
        currentIndex = currentIndex + 1
    }
    
    @IBAction func acceptActionTap(sender: UIButton) {
        currentCompletedTask.setValue("completed", forKey: "status")
        loadingAlert("Task complete...", viewController: self)
        publicDatabase.saveRecord(currentCompletedTask) { (currentTask, error) -> Void in
            if error != nil {
                print("error marking task as completed: \(error))")
            } else {
                print("sucesssfully saved task")
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.layOutDataForCompletedRecord()
                })
            })
        }
    }
    
    //MARK: Delegate Functions
    
    //MARK: Segues
}
