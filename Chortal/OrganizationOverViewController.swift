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
    //MARK: Properties
    var organization : String?
    var allMembers = [CKRecord]()
    var isMember: Bool?
    
    //MARK: Outlets
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.title = userDefaults.valueForKey("currentOrgName") as? String
    }
    
    override func viewDidAppear(animated: Bool) {
        if currentOrg!["members"] != nil {
            getMembers()
        } else {
            self.errorAlert("Oops!" , message: "There are no members in your group.")
        }
    }
    
    //MARK: Custom Functions
    func getMembers() {
        loadingAlert("Loading Members...", viewController: self)
        for memberRef in currentOrg!["members"] as! [CKReference] {
            print("fetching member ref: \(memberRef)")
            publicDatabase.fetchRecordWithID(memberRef.recordID, completionHandler: { (member , error) -> Void in
                if error != nil {
                    print(error?.description)
                }else {
                    self.allMembers.append(member!)
                    print("all members array: \(self.allMembers)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                    if memberRef == (currentOrg!["members"] as! [CKReference]).last {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            })
        }
    }
    
    //MARK: Actions
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        if isMember == true {
            performSegueWithIdentifier("orgOverviewToMember", sender: self)
        } else {
            performSegueWithIdentifier("orgOverviewToAdmin", sender: self)
        }
        
        if backButton.enabled == true {
            backButton.enabled = false
        }
    }
    
    //MARK: TableView Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberID") as! MemberSelectTableViewCell
        
        let cellRecord = allMembers[indexPath.row]
        let imageAsset = cellRecord["profile_picture"] as? CKAsset
        let image = UIImage(data: NSData(contentsOfURL: (imageAsset?.fileURL)!)!)
        
        cell.profileImageView?.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 10, 40, 40)
        cell.profileImageView.image = image
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
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToMemberDetail" {
            let dvc = segue.destinationViewController as! MemberDetailViewController
            let indexPath = tableView.indexPathForCell(sender as! MemberSelectTableViewCell)
            dvc.selectedMember = allMembers[indexPath!.row]
        }
    }
    
    @IBAction func unwindToOrganizationOverview(segue: UIStoryboardSegue) {
    
    }
}
