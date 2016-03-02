//
//  MemberSelectViewController.swift
//  Chortal
//
//  Created by Jonathan Jones on 2/18/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit
import QuartzCore

class MemberSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    var selectedIndexPath: NSIndexPath?
    var memberArray = [CKRecord]()
    var orgRecord: CKRecord?
    
    //MARK: Outlets
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLabel.text = userDefaults.valueForKey("currentOrgName") as? String
        memberTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.automaticallyAdjustsScrollViewInsets = false
        
        
//        let inset = UIEdgeInsetsMake(10, 10, 10, 10)
//        memberTableView.contentInset = inset
        
        
        getCurrentOrganization()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        loadingAlert("Loading members...", viewController: self)
    }
    
    //MARK: Custom Functions
    func getCurrentOrganization() {
        let currentOrgUID = userDefaults.objectForKey("currentOrgUID") as! String
        let predicate = NSPredicate(format: "uid == %@", currentOrgUID)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                checkError(error!, view: self)
            } else {
                if results != nil {
                    self.orgRecord = results![0]
                    self.fetchMembers(self.orgRecord!)
                } else {
                    
                    print("Looks like there is no Org with that UID. Uh-oh!")
                }
            }
        }
    }
    
    func fetchMembers(currentOrganizationRecord: CKRecord) {
        let memRefArray = currentOrganizationRecord.valueForKey("members") as! NSMutableArray
        for reference in memRefArray {
            publicDatabase.fetchRecordWithID(reference.recordID, completionHandler: { (record, error) -> Void in
                if error != nil {
                    checkError(error!, view: self)
                }
                self.memberArray.append(record!)
                dispatch_async(dispatch_get_main_queue()) {
                    self.memberTableView.reloadData()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    //MARK: IBActions
    
    @IBAction func addMemberButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("joinOrgSegue", sender: self)
    }
    
    //MARK: Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberID") as! MemberSelectTableViewCell
        
        let cellRecord = memberArray[indexPath.row]
        let imageAsset = cellRecord["profile_picture"] as? CKAsset
        let image = UIImage(data: NSData(contentsOfURL: (imageAsset?.fileURL)!)!)
        cell.profileImageView?.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 40, 40)
        cell.profileImageView.image = image
        //cell.imageView!.contentMode = UIViewContentMode.ScaleToFill
        cell.profileImageView!.layer.cornerRadius = (cell.profileImageView!.frame.height)/2
        cell.profileImageView?.layer.masksToBounds = true
        cell.profileImageView?.clipsToBounds = true

        cell.memberNameLabel!.text = cellRecord.valueForKey("name") as? String
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = chortalGreen.CGColor
        cell.layer.borderWidth = 0.5
        cell.contentView.frame = cell.frame

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        let selectedMember = memberArray[indexPath.row]
        let selelectedName = selectedMember.valueForKey("name")
        userDefaults.setValue(selelectedName, forKey: "currentUserName")
        
        performSegueWithIdentifier("memSelectSegue", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberArray.count
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "joinOrgSegue" {
            let dvc = segue.destinationViewController as! WelcomeViewController
            dvc.seguedFromMemberSelect = true
            dvc.orgRecord = orgRecord
            
        } else if segue.identifier == "memSelectSegue" {
            
            
        }
    }
    
    
}
