//
//  MemberSelectViewController.swift
//  Chortal
//
//  Created by Jonathan Jones on 2/18/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

let cka = CloudKitAccess()
let userDefaults = NSUserDefaults.standardUserDefaults()

class MemberSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    var memberArray = [CKRecord]()
    var orgRecord: CKRecord?
    
    //MARK: Outlets
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var welcomeLabel: UILabel!
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLabel.text = userDefaults.valueForKey("currentOrgName") as? String
        currentOrg()
        
    }
    
    //MARK: Custom Functions
    func currentOrg() {
        let currentOrg = userDefaults.objectForKey("currentOrgUID") as! String
        let predicate = NSPredicate(format: "uid == %@", currentOrg)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        
        cka.publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print("Error: \(error?.description)")
            } else {
                if results != nil {
                    print(results)
                    let record = results![0]
                    self.orgRecord = record
                    print("Org Record: \(self.orgRecord) -----------")
                    self.fetchRecords(self.orgRecord!)
                    
                } else {
                    
                    print("Looks like there is no Org with that UID. Uh-oh!")
                }
            }
        }
    }
    
    func fetchRecords (currentRec: CKRecord) {
        let memRefArray = currentRec.valueForKey("members") as! NSMutableArray
        for reference in memRefArray {
            cka.publicDatabase.fetchRecordWithID(reference.recordID, completionHandler: { (record, error) -> Void in
                if error != nil {
                    print(error?.description)
                }
                self.memberArray.append(record!)
                print(record!.valueForKey("name")!)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.memberTableView.reloadData()
                }
                
            })
            
            
            
        }
        
    }
    
    //MARK: IBActions
    
    
    //MARK: Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberID")
        
        let cellRecord = self.memberArray[indexPath.row]
        cell?.textLabel!.text = cellRecord.valueForKey("name") as? String
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberArray.count
    }
    
    //MARK: Segue
    
    
}
