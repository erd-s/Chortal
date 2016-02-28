//
//  Constants.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/19/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import Foundation
import CloudKit


let userDefaults = NSUserDefaults.standardUserDefaults()
let container = CKContainer.defaultContainer()
let publicDatabase = container.publicCloudDatabase
let orgUID = userDefaults.stringForKey("currentOrgUID")
let memberName = userDefaults.stringForKey("currentUserName")
let pushNotificationsSet = userDefaults.boolForKey("pushNotificationsSet")
let chortalGreen = UIColor(red: 3 / 255, green: 117 / 255, blue: 60 / 255, alpha: 0.9)
var currentMember: CKRecord?
var currentOrg: CKRecord?
var currentTask: CKRecord?
var currentAdmin: CKRecord?
