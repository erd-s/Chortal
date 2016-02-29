//
//  OrganizationOverViewController.swift
//  Chortal
//
//  Created by Kanybek Zhagusaev on 2/22/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class OrganizationOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var organization : String?
    var allMembers = [CKRecord]()
    
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.title = userDefaults.valueForKey("currentOrgName") as? String
        
        getMembers()
        
    }
    
    func getMembers() {
        
        for memberRef in currentOrg!["members"] as! [CKReference] {
            publicDatabase.fetchRecordWithID(memberRef.recordID, completionHandler: { (member , error) -> Void in
                if error != nil {
                    print(error?.description)
                }else {
                    self.allMembers.append(member!)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
                
            })
        }
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        if backButton.enabled == true {
            self.dismissViewControllerAnimated(true, completion: nil)
            backButton.enabled = false
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberID") as! MemberSelectTableViewCell
        
        let cellRecord = allMembers[indexPath.row]
        let imageAsset = cellRecord["profile_picture"] as? CKAsset
        let image = UIImage(data: NSData(contentsOfURL: (imageAsset?.fileURL)!)!)
        cell.profileImageView?.frame = CGRectMake(cell.frame.origin.x + 10, cell.frame.origin.y + 10, 80, 80)
        cell.profileImageView.image = image
        //cell.imageView!.contentMode = UIViewContentMode.ScaleToFill
        cell.profileImageView!.layer.cornerRadius = (cell.profileImageView!.frame.height)/2
        cell.profileImageView?.layer.masksToBounds = true
        cell.profileImageView?.clipsToBounds = true
        
        cell.memberNameLabel!.text = cellRecord.valueForKey("name") as? String
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 1.0
        cell.contentView.frame = cell.frame
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    
}
