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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeMemberLabel?.text = "Welcome \(userDefaults.valueForKey("currentUserName")!)"
        memberNameLabel?.text = "\(userDefaults.valueForKey("currentUserName")!) Overview"
        organizationLabel?.text = "\(userDefaults.valueForKey("currentOrgName")!)"
    }
    
    @IBAction func unwindFromTaskView(segue: UIStoryboardSegue) {
        
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
}
