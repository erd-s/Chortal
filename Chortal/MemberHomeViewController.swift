//
//  MemberHomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class MemberHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: Properties
    
    
    //MARK: Outlets
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var taskTableView: UITableView!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Custom Functions
    
    //MARK: IBActions
    @IBAction func menuButtonTapped(sender: UIBarButtonItem) {
    }
    
    @IBAction func myTaskButtonTap(sender: UIBarButtonItem) {
    }
    //MARK: Delegate Functions
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pizza")!
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    //MARK: Segues
    
}
