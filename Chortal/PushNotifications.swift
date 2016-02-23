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
//    print(userDefaults.boolForKey("push_TaskApproved"))
//    if userDefaults.boolForKey("push_TaskApproved") {
        print("starting predicating")
        let myTaskPredicate = NSPredicate(format: "member == %@", currentUser!)
        let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
        let myFinishedTaskPredicate = NSPredicate(format: "status == approved")
        let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myTaskPredicate, myOrgPredicate, myFinishedTaskPredicate])
        
        let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        publicDatabase.saveSubscription(subscription, completionHandler: { (subscription, error) -> Void in
            if error != nil {
                print("error saving subscription: \(error!)")
            } else {
                print("subscription: \(subscription) successfully set")
            }
        })
    }
//}


//  Find the best time to subscribe to these push notifications (one time only, then update)
//  Predicate based on status of a task
//  Add predications based on push notifications