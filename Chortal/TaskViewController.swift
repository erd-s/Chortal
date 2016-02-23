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
    var currentTask: CKRecord?
    
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
        fetchRecord()
        collectionViewFlow.itemSize = CGSizeMake(collectionView.frame.width/3, collectionView.frame.width/3)
        
        
    }
    
    //MARK: Custom Functions
    func fetchRecord () {
        let taskRef = currentUser?.valueForKey("current_task") as! CKReference
        publicDatabase.fetchRecordWithID(taskRef.recordID) { (fetchedRecord, error) -> Void in
            if error != nil {
                print("Error: \(error?.description)")
            } else {
                if fetchedRecord != nil {
                    self.currentTask = fetchedRecord
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.taskNameLabel.text = self.currentTask?.valueForKey("name") as? String
                        self.descriptionTextView.text = self.currentTask?.valueForKey("description") as? String
                    })
                    
                    
                    
                    
                    
                }
                
                
                
            }
            
        }
        
    }
    
    
    
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
    
}


//MARK: Segues


