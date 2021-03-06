//
//  MemberSidebarTableViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/21/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class MemberSidebarTableViewController: UITableViewController {
    
    @IBOutlet weak var welcomeMemberLabel: UILabel!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    
    @IBOutlet weak var welcomeCell: UITableViewCell!
    @IBOutlet weak var memberNameCell: UITableViewCell!
    @IBOutlet weak var myTaskCell: UITableViewCell!
    @IBOutlet weak var organizationOverviewCell: UITableViewCell!
    @IBOutlet weak var settingsCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        let bottomImage = UIImage(named: "cell_bottom")
        let middleImage = UIImage(named: "cell_middle")
        let topImage = UIImage(named: "cell_top")
        
        
        welcomeCell.contentView
        
        let topCellView = UIImageView()
        topCellView.frame = welcomeCell.frame
        topCellView.image = topImage
        topCellView.contentMode = UIViewContentMode.ScaleToFill
        
        let middleCellView = UIImageView()
        middleCellView.frame = welcomeCell.frame
        middleCellView.image = middleImage
        middleCellView.contentMode = UIViewContentMode.ScaleToFill
        
        let middleCellView2 = UIImageView()
        middleCellView2.frame = welcomeCell.frame
        middleCellView2.image = middleImage
        middleCellView2.contentMode = UIViewContentMode.ScaleToFill
        
        let middleCellView3 = UIImageView()
        middleCellView3.frame = welcomeCell.frame
        middleCellView3.image = middleImage
        middleCellView3.contentMode = UIViewContentMode.ScaleToFill
        
        let middleCellView4 = UIImageView()
        middleCellView4.frame = welcomeCell.frame
        middleCellView4.image = middleImage
        middleCellView4.contentMode = UIViewContentMode.ScaleToFill
        
        let bottomCellView = UIImageView()
        bottomCellView.frame = welcomeCell.frame
        bottomCellView.image = bottomImage
        bottomCellView.contentMode = UIViewContentMode.ScaleToFill
        
        welcomeCell.backgroundView = topCellView
        memberNameCell.backgroundView = middleCellView
        myTaskCell.backgroundView = middleCellView2
        organizationOverviewCell.backgroundView = middleCellView3
        settingsCell.backgroundView = bottomCellView
        
        welcomeCell.backgroundColor = UIColor.clearColor()
        memberNameCell.backgroundColor = UIColor.clearColor()
        myTaskCell.backgroundColor = UIColor.clearColor()
        organizationOverviewCell.backgroundColor = UIColor.clearColor()
        settingsCell.backgroundColor = UIColor.clearColor()
        
        welcomeMemberLabel?.text = "Welcome \(userDefaults.valueForKey("currentUserName")!)"
        memberNameLabel?.text = "\(userDefaults.valueForKey("currentUserName")!) Overview"
        organizationLabel?.text = "\(userDefaults.valueForKey("currentOrgName")!) Details"
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.automaticallyAdjustsScrollViewInsets = false
        let inset = UIEdgeInsetsMake(30, 0, 0, 0)
        tableView.contentInset = inset
        
        let imageView = UIImageView()
        imageView.frame = self.view.frame
        imageView.image = UIImage(named: "common_bg")
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.backgroundView = imageView
        
    }
    
    @IBAction func unwindFromTaskView(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromOrgOverviewToMemberSidebar(segue: UIStoryboardSegue) {
        
        
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "takeTaskSegue" {
//            if currentTask == nil {
//                errorAlert("Oops!", message: "You don't have a task.")
//            }
        } else if segue.identifier == "OrgCellID" {
            let dvc = segue.destinationViewController as! OrganizationOverViewController
            dvc.isMember = true
        } else if segue.identifier == "showMemberDetail" {
            let dvc = segue.destinationViewController as! MemberDetailViewController
            dvc.selectedMember = currentMember
            dvc.fromMember = true
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "currentTask" {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if currentTask == nil {
                    self.errorAlert("Oops!", message: "You don't have a task.")
                } else {
                    self.performSegueWithIdentifier("takeTaskSegue", sender: self)
                }
            })
            
        } else if cell?.reuseIdentifier == "settings" {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("settingsSegue", sender: self)
            })
            
        } else if cell?.reuseIdentifier == "orgOverview" {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("OrgCellID", sender: self)
            })
        }
    }
    
}
