//
//  AdminSidebarTableViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/21/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class AdminSidebarTableViewController: UITableViewController {

    
    @IBOutlet weak var welcomeAdminLabel: UILabel!
    @IBOutlet weak var organizationOverviewLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeAdminLabel?.text = "Welcome \(userDefaults.valueForKey("adminName")!)"
        organizationOverviewLabel?.text = "\(userDefaults.valueForKey("currentOrgName")!) Overview"

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

  }
