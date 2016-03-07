//
//  AdminSidebarTableViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/21/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class AdminSidebarTableViewController: UITableViewController {
    
    
    @IBOutlet weak var welcomeAdminLabel: UILabel!
    @IBOutlet weak var organizationOverviewLabel: UILabel!
    
    
    @IBOutlet weak var welcomeAdmin: UITableViewCell!
    @IBOutlet weak var completedTask: UITableViewCell!
    @IBOutlet weak var organizationOverview: UITableViewCell!
    @IBOutlet weak var settingsCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeAdminLabel?.text = "Welcome \(userDefaults.valueForKey("adminName")!)"
        organizationOverviewLabel?.text = "\(userDefaults.valueForKey("currentOrgName")!) Overview"
        
        let bottomImage = UIImage(named: "cell_bottom")
        let middleImage = UIImage(named: "cell_middle")
        let topImage = UIImage(named: "cell_top")
        
        
        welcomeAdmin.contentView
        
        let topCellView = UIImageView()
        topCellView.frame = welcomeAdmin.frame
        topCellView.image = topImage
        topCellView.contentMode = UIViewContentMode.ScaleToFill
        
        let middleCellView = UIImageView()
        middleCellView.frame = welcomeAdmin.frame
        middleCellView.image = middleImage
        middleCellView.contentMode = UIViewContentMode.ScaleToFill
        
        let middleCellView2 = UIImageView()
        middleCellView2.frame = welcomeAdmin.frame
        middleCellView2.image = middleImage
        middleCellView2.contentMode = UIViewContentMode.ScaleToFill
        
        let bottomCellView = UIImageView()
        bottomCellView.frame = welcomeAdmin.frame
        bottomCellView.image = bottomImage
        bottomCellView.contentMode = UIViewContentMode.ScaleToFill
        
        welcomeAdmin.backgroundView = topCellView
        completedTask.backgroundView = middleCellView
        organizationOverview.backgroundView = middleCellView2
        settingsCell.backgroundView = bottomCellView
        
        welcomeAdmin.backgroundColor = UIColor.clearColor()
        completedTask.backgroundColor = UIColor.clearColor()
        organizationOverview.backgroundColor = UIColor.clearColor()
        settingsCell.backgroundColor = UIColor.clearColor()
        
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "adminSidebarToOrgOverview" {
            let dvc = segue.destinationViewController as! OrganizationOverViewController
            dvc.isMember = false
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "completedTask" {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                if currentTask == nil {
//                    self.errorAlert("Oops!", message: "There are no completed tasks.")
//                } else {
                    self.performSegueWithIdentifier("completedTaskSegue", sender: self)
//                }
            })
            
        } else if cell?.reuseIdentifier == "settings" {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("adminSettingsSegue", sender: self)
            })
            
        } else if cell?.reuseIdentifier == "orgOverView" {
            if currentOrg!["members"] != nil {
                if (currentOrg!["members"] as! [CKReference]).count > 0 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("adminSidebarToOrgOverview", sender: self)
                    })
                }
            } else {
                errorAlert("Oops!", message: "You have no members in your group.")
            }
        }
    }
    
    @IBAction func unwindFromOrgOverviewToAdmin (segue: UIStoryboardSegue){
        
    }
    
}
