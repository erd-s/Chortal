//
//  PushNotifications.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/23/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

var adminSubscriptionsArray = [CKSubscription]()
var memberSubscriptionsArray = [CKSubscription]()

//  Find the best time to subscribe to these push notifications (one time only, then update)
//  They may not need to be based on userDefaults if they are called and then deleted when
//  a user unsubscribes.

func setAdminPushNotifications() {
    pushNotificationTaskCompleted()
    pushNotificationMemberJoined()
    pushNotifcationTaskTaken()
    
    
    let modifySubscriptionsOperation = CKModifySubscriptionsOperation(subscriptionsToSave: adminSubscriptionsArray, subscriptionIDsToDelete: nil)
    publicDatabase.addOperation(modifySubscriptionsOperation)
}

func setMemberPushNotifications() {
    pushNotificationNewTaskAdded()
    pushNotificationTaskRejected()
    pushNotificationTaskAssignedToUser()
    pushNotificationTaskApproved()
    
    let modifySubscriptionsOperation = CKModifySubscriptionsOperation(subscriptionsToSave: memberSubscriptionsArray, subscriptionIDsToDelete: nil)
    publicDatabase.addOperation(modifySubscriptionsOperation)
}


func pushNotificationTaskApproved(){
    let myTaskPredicate = NSPredicate(format: "member == %@", currentMember!)
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let myFinishedTaskPredicate = NSPredicate(format:  "%K == %@", "status", "approved")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myTaskPredicate, myOrgPredicate, myFinishedTaskPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    memberSubscriptionsArray.append(subscription)
}

func pushNotificationTaskRejected() {
    let myTaskPredicate = NSPredicate(format: "member == %@", currentMember!)
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let myFinishedTaskPredicate = NSPredicate(format:  "%K == %@", "status", "rejected")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myTaskPredicate, myOrgPredicate, myFinishedTaskPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    memberSubscriptionsArray.append(subscription)
}

func pushNotificationNewTaskAdded() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let taskStatusPredicate = NSPredicate(format:  "%K == %@", "status", "unassigned")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    memberSubscriptionsArray.append(subscription)
}

func pushNotificationTaskAssignedToUser() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let taskAssignedPredicate = NSPredicate(format: "member == %@", currentMember!)
    let taskStatusPredicate = NSPredicate(format:  "%K == %@", "status", "inProgress")
    let adminAssignedPredicate = NSPredicate(format: "lastModifiedUserRecordID == %@", (currentOrg?.creatorUserRecordID)!)
    // adminAssignedPredicate makes sure that the one modifying the task is the admin
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskAssignedPredicate, adminAssignedPredicate, taskStatusPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    memberSubscriptionsArray.append(subscription)
}

func pushNotificationMemberJoined() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let subscription = CKSubscription(recordType: "Member", predicate: myOrgPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    adminSubscriptionsArray.append(subscription)
}

func pushNotifcationTaskTaken() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let taskStatusPredicate = NSPredicate(format: "%K == %@", "status", "inProgress")
    let memberAssignedPredicate = NSPredicate(format: "lastModifiedUserRecordID != %@", (currentOrg?.creatorUserRecordID)!)
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate, memberAssignedPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    adminSubscriptionsArray.append(subscription)
}

func pushNotificationTaskCompleted() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrg!)
    let taskStatusPredicate = NSPredicate(format: "%K == %@", "status", "pending")
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    adminSubscriptionsArray.append(subscription)
}












