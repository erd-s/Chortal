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
        var taskArray = currentUser?.valueForKey("current_tasks") as! [CKRecord]
        let index = taskArray.indexOf(currentTask!)
        taskArray.removeAtIndex(index!)
        
        currentUser?.setValue(taskArray, forKey: "current_tasks")
        
        
        
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


