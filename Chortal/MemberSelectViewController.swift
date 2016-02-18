//
//  MemberSelectViewController.swift
//  Chortal
//
//  Created by Jonathan Jones on 2/18/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

let ckh = CloudKitAccess()

class MemberSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    var memberArray: [CKRecord]?
    
    //MARK: Outlets
   
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: Custom Functions
    func currentOrg() {

    }
    
    //MARK: IBActions

    
    //MARK: Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberID")
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    //MARK: Segue

    
}
