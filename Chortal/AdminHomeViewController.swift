//
//  AdminHomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class AdminHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Properties
    
    
    //MARK: Outlets
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Custom Functions
    
    
    //MARK: IBActions
    @IBAction func menuButtonTap(sender: AnyObject) {
    }
    
    @IBAction func createTaskButtonTap(sender: AnyObject) {
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
