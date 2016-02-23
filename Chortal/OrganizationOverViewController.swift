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
    var allMembers : [CKRecord]?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    func getMembers() {
        let predicate = NSPredicate(format: "organization == %@", currentOrg!.recordID)
        let query = CKQuery(recordType: "Member", predicate: predicate)
        
        publicDatabase.performQuery(query, inZoneWithID: nil) { (memberArray, error) -> Void in
            if error != nil {
                print(error?.description)
                
            }else {
                if memberArray?.count > 0 {
                    self.allMembers = memberArray as [CKRecord]!
                    
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })

            }
            
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")
       let members = self.allMembers![indexPath.row]
        cell?.textLabel?.text = members.valueForKey("name") as? String 
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMembers!.count
    }
    
    
}
