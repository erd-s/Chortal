//
//  PushNotifications.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/23/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import Foundation
import CloudKit


func pushNotificationTaskApprovedSet() {
//    if userDefaults.boolForKey("push_TaskApproved") {
        print("starting predicating")
//        let approvedPredicate = NSPredicate(format: "status == approved")
        let myTaskPredicate = NSPredicate(format: "member == %@", currentUser!)
        let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
        let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myTaskPredicate, myOrgPredicate])
        
        let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
        publicDatabase.saveSubscription(subscription, completionHandler: { (subscription, error) -> Void in
            if error != nil {
                print("error saving subscription: \(error)")
            } else {
                print("subscription: \(subscription) successfully set")
            }
        })
//    }
}
