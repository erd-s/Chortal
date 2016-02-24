//
//  PushNotifications.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/23/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import Foundation
import CloudKit


//  Find the best time to subscribe to these push notifications (one time only, then update)
//  They may not need to be based on userDefaults if they are called and then deleted when
//  a user unsubscribes.

func pushNotificationTaskApproved() {
    let myTaskPredicate = NSPredicate(format: "member == %@", currentMember!)
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let myFinishedTaskPredicate = NSPredicate(format: "status == approved")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myTaskPredicate, myOrgPredicate, myFinishedTaskPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    publicDatabase.saveSubscription(subscription, completionHandler: { (newSubscription, error) -> Void in
        if error != nil {
            print("error saving task approved subscription: \(error!)")
        } else {
            print("m-subscription for task approved  successfully set")
        }
    })
}

func pushNotificationTaskRejected() {
    let myTaskPredicate = NSPredicate(format: "member == %@", currentMember!)
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let myFinishedTaskPredicate = NSPredicate(format: "status == rejected")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myTaskPredicate, myOrgPredicate, myFinishedTaskPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    publicDatabase.saveSubscription(subscription, completionHandler: { (newSubscription, error) -> Void in
        if error != nil {
            print("error saving task rejected subscription: \(error!)")
        } else {
            print("m-subscription for task rejected successfully set")
        }
    })
}

func pushNotificationNewTaskAdded() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let taskStatusPredicate = NSPredicate(format: "status == unassigned")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    
    publicDatabase.saveSubscription(subscription, completionHandler: { (newSubscription, error) -> Void in
        if error != nil {
            print("error saving new task subscription: \(error)")
        } else {
            print("m-subscription for new task successfully set")
        }
    })
}

func pushNotificationTaskAssignedToUser() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let taskAssignedPredicate = NSPredicate(format: "member == %@", currentMember!)
    let taskStatusPredicate = NSPredicate(format: "status == inProgress")
    let adminAssignedPredicate = NSPredicate(format: "lastModifiedUserRecordID == %@", (currentOrg?.creatorUserRecordID)!)
    // adminAssignedPredicate makes sure that the one modifying the task is the admin
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskAssignedPredicate, adminAssignedPredicate, taskStatusPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    publicDatabase.saveSubscription(subscription, completionHandler: { (newSubscription, error) -> Void in
        if error != nil {
            print("error saving new task subscription: \(error)")
        } else {
            print("m-subscription for new task successfully set")
        }
    })
}

func pushNotificationMemberJoined() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let subscription = CKSubscription(recordType: "Member", predicate: myOrgPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    publicDatabase.saveSubscription(subscription, completionHandler: { (newSubscription, error) -> Void in
        if error != nil {
            print("error saving new member subscription: \(error)")
        } else {
            print("a-subscription for new member successfully set")
        }
    })
}

func pushNotifcationTaskTaken() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let taskStatusPredicate = NSPredicate(format: "status == inProgress")
    let memberAssignedPredicate = NSPredicate(format: "lastModifiedUserRecordID != %@", (currentOrg?.creatorUserRecordID)!)
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate, memberAssignedPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    publicDatabase.saveSubscription(subscription, completionHandler: { (newSubscription, error) -> Void in
        if error != nil {
            print("error saving task taken subscription: \(error)")
        } else {
            print("a-subscription for task taken successfully set")
        }
    })
}

func pushNotificationTaskCompleted() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let taskStatusPredicate = NSPredicate(format: "status == pending")
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    publicDatabase.saveSubscription(subscription, completionHandler: { (newSubscription, error) -> Void in
        if error != nil {
            print("error saving task completed subscription: \(error)")
        } else {
            print("a-subscription for task completed successfully set")
        }
    })

}












