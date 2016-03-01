//
//  TaskViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class TaskViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    var images = [UIImage]()
    var memberPendingArray: [CKReference]?
    var imageAssetArray: [CKAsset]?
    var dueDate: NSDate?
    var x: Int?
    
    //MARK: Outlets
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var collectionViewFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewFlow.itemSize = CGSizeMake(collectionView.frame.width/2, collectionView.frame.width/2)
        
        taskNameLabel.text = currentTask?.valueForKey("name") as? String
        descriptionLabel.text = currentTask?.valueForKey("description") as? String
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        
        dueDate = currentTask?["due"] as? NSDate
        let timeInterval = (dueDate?.timeIntervalSinceNow)! as NSTimeInterval
        
        if timeInterval < 0 {
            timerLabel.textColor = UIColor.redColor()
            timerLabel.text = "Past due!"
            
        } else if timeInterval < 3600 {
            let minutesRemaining = timeInterval / 60
            
            if Int(minutesRemaining) == 1 {
                timerLabel.text = "Due in \(Int(minutesRemaining)) minute!"
            } else {
                timerLabel.text = "Due in \(Int(minutesRemaining)) minutes!"
            }
            timerLabel.textColor = UIColor.orangeColor()
            
        } else if timeInterval < 86400 {
            let hoursRemaining = timeInterval / 3600
            
            if Int(hoursRemaining) == 1 {
                timerLabel.text = "Due in \(Int(hoursRemaining)) hour"
            } else {
                timerLabel.text = "Due in \(Int(hoursRemaining)) hours"
            }
            
        } else if timeInterval < 1209600 {
            let daysRemaining = timeInterval / 86400
            
            if Int(daysRemaining) == 1 {
                timerLabel.text = "Due in \(Int(daysRemaining)) day"
            } else {
                timerLabel.text = "Due in \(Int(daysRemaining)) days"
            }
            
        } else {
            let weeksRemaining = timeInterval / 604800
            
            if Int(weeksRemaining) == 1 {
                timerLabel.text = "Due in \(Int(weeksRemaining)) week"
            } else {
                timerLabel.text = "Due in \(Int(weeksRemaining)) weeks"
            }
            
        }

        x = 0
    }
    
    //MARK: Custom Functions
    
    
    //MARK: IBActions
    @IBAction func onCameraButtonTapped(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true;
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        
    }
    
    @IBAction func abandonTaskButtonTapped(sender: UIButton) {
        loadingAlert("Abandoning task...", viewController: self)
        var taskRefArray = currentMember!.valueForKey("current_tasks") as! [CKReference]
        for reference in taskRefArray {
            if reference.recordID == currentTask?.recordID {
                let refIndex = taskRefArray.indexOf(reference)
                taskRefArray.removeAtIndex(refIndex!)
            }
        }
        currentTask?.setValue(nil, forKey: "member")
        currentTask?.setValue("unassigned", forKey: "status")
        currentMember?.setValue(taskRefArray, forKey: "current_tasks")
        modifyRecords([currentMember!, currentTask!])
    }
    
    func modifyRecords (records: [CKRecord]) {
        print("Modify records function called")
        let saveRecordsOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        
        publicDatabase.addOperation(saveRecordsOperation)
        
        saveRecordsOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print(error!.description)
            }else {
                print("Successfully saved")
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.performSegueWithIdentifier("unwindFromTaskView", sender: self)
                })
            }
        }
    }
    
    @IBAction func submitTaskTapped(sender: UIButton) {
        imageAssetArray = [CKAsset]()
        if (currentTask!["photo_required"] as! String) == "true" && images.count == 0 {
            errorAlert("Error", message: "Please add a photo to submit this task")
        } else {
            
            loadingAlert("Submitting task...", viewController: self)
            var taskRefArray = currentMember!.valueForKey("current_tasks") as! [CKReference]
            
            if currentMember!["pending_tasks"] != nil {
                memberPendingArray = currentMember!["pending_tasks"] as? [CKReference]
            } else {
                memberPendingArray = [CKReference]()
            }
            
            for reference in taskRefArray {
                if reference.recordID == currentTask?.recordID {
                    let refIndex = taskRefArray.indexOf(reference)
                    taskRefArray.removeAtIndex(refIndex!)
                    memberPendingArray?.append(reference)
                    currentMember?.setValue(taskRefArray, forKey: "current_tasks")
                    currentMember?.setValue(memberPendingArray, forKey: "pending_tasks")
                    currentTask?.setValue("pending", forKey: "status")
                    
                    let takenDate = currentTask?.valueForKey("taskTaken") as! Double
                    
                    let elapsedTime = NSDate.timeIntervalSinceReferenceDate()
                    
                    
                    let timeTaken = elapsedTime - takenDate
                    print("Time Taken to complete task:\(timeTaken)")
                    
                    currentTask?.setValue(timeTaken, forKey: "taskCompletedTime")
                    
                    if images.count > 0 {
                        for image in images {
                            print(" image: \(image.description)")
                            let data = UIImagePNGRepresentation(image)
                            let filename = getDocumentsDirectory().stringByAppendingPathComponent("\(x).png")
                            x = x!+1
                            data!.writeToFile(filename, atomically: true)
                            let imageAsset = CKAsset(fileURL: NSURL(fileURLWithPath: filename))
                            
                            
                            
                            
                            
                            
                            //
                            //                                let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0] as NSString
                            //                                let imageFilePath = documentDirectory.stringByAppendingPathComponent("lastimage")
                            //                                print(imageFilePath)
                            //                                UIImagePNGRepresentation(image)?.writeToFile(imageFilePath, atomically: true)
                            //                                let imageAsset = CKAsset(fileURL: NSURL(fileURLWithPath: imageFilePath))
                            //
                            //
                            //
                            //
                            
                            print(imageAsset)
                            imageAssetArray?.append(imageAsset)
                        }
                        
                        currentTask?.setObject(imageAssetArray, forKey: "photos")
                        print(imageAssetArray!.count)
                        print(currentTask!["photos"])
                        
                    }
                    
                    
                    modifyRecords([currentMember!, currentTask!])
                }
            }
        }
    }
    
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    //MARK: Delegate Functions
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pizza", forIndexPath: indexPath) as! CustomCamCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        cell.imageView.sizeToFit()
        
        return cell
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        images.append(chosenImage)
        picker.dismissViewControllerAnimated(true, completion: nil)
        noPhotosLabel.hidden = true
        collectionView.reloadData()
    }
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindFromTaskView" {
        }
    }
}





