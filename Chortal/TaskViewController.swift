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
    
    //MARK: Outlets
    
    @IBOutlet weak var collectionViewFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    var images = [UIImage]()
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewFlow.itemSize = CGSizeMake(collectionView.frame.width/3, collectionView.frame.width/3)
        
        taskNameLabel.text = currentTask?.valueForKey("name") as? String
        descriptionTextView.text = currentTask?.valueForKey("description") as? String
        
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
        performSegueWithIdentifier("unwindFromTaskView", sender: self)
        
    }
    
    @IBAction func abandonTaskButtonTapped(sender: UIButton) {
        loadingAlert("Abandoning task...", viewController: self)
        var taskRefArray = currentUser!.valueForKey("current_tasks") as! [CKReference]
        for reference in taskRefArray {
            if reference.recordID == currentTask?.recordID {
                let refIndex = taskRefArray.indexOf(reference)
                taskRefArray.removeAtIndex(refIndex!)
            }
        }
        currentTask?.setValue(nil, forKey: "member")
        print(currentTask?.valueForKey("member"))
        currentTask?.setValue("false", forKey: "inProgress")
        currentUser?.setValue(taskRefArray, forKey: "current_tasks")
        modifyRecords([currentUser!, currentTask!])
        
        
    }
    func modifyRecords (records: [CKRecord]) {
        print("Modify records function called")
        let modOpp = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modOpp.savePolicy = .ChangedKeys
        modOpp.atomic = true
        
        publicDatabase.addOperation(modOpp)
        
        modOpp.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
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
    
    
    //MARK: Delegate Functions
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pizza", forIndexPath: indexPath) as! CustomCamCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        
        return cell
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        images.append(chosenImage)
        picker.dismissViewControllerAnimated(true, completion: nil)
        collectionView.reloadData()
        
        
    }
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindFromTaskView" {
            
        }
    }
}





