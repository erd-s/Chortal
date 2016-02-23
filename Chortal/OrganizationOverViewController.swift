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

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")
       let members = allMembers[indexPath.row]
        cell?.textLabel?.text = members.valueForKey("name") as? String 
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    
}
