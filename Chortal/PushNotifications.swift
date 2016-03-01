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
let currentOrganizationReference = CKReference(record: currentOrg!, action: .None)
let currentMemberReference = CKReference(record: currentMember!, action: .None)


//  Find the best time to subscribe to these push notifications (one time only, then update)
//  They may not need to be based on userDefaults if they are called and then deleted when
//  a user unsubscribes.

func setAdminPushNotifications() {
    pushNotificationTaskCompleted()
    pushNotificationMemberJoined()
    pushNotificationTaskTaken()
    
    let modifySubscriptionsOperation = CKModifySubscriptionsOperation(subscriptionsToSave: adminSubscriptionsArray, subscriptionIDsToDelete: nil)
    modifySubscriptionsOperation.modifySubscriptionsCompletionBlock = { saved, deleted, error in
        if error != nil {
            print(error)
        } else {
            print("saved push notification subcriptions for admin")
        }
    }
    
    publicDatabase.addOperation(modifySubscriptionsOperation)
}

func setMemberPushNotifications() {
    pushNotificationNewTaskAdded()
    pushNotificationTaskRejected()
    pushNotificationTaskAssignedToUser()
    pushNotificationTaskApproved()
    
    let modifySubscriptionsOperation = CKModifySubscriptionsOperation(subscriptionsToSave: memberSubscriptionsArray, subscriptionIDsToDelete: nil)
    modifySubscriptionsOperation.modifySubscriptionsCompletionBlock = { saved, deleted, error in
        if error != nil {
            print(error)
        } else {
            print("saved push notification subcriptions for member")
        }
    }
    
    publicDatabase.addOperation(modifySubscriptionsOperation)
}


func pushNotificationTaskApproved(){
    let myTaskPredicate = NSPredicate(format: "member == %@", currentMemberReference)
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrganizationReference)
    let myFinishedTaskPredicate = NSPredicate(format:  "%K == %@", "status", "approved")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myTaskPredicate, myOrgPredicate, myFinishedTaskPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    
    let notification = CKNotificationInfo()

    notification.alertBody = "Your task has been approved."
    subscription.notificationInfo = notification
    
    memberSubscriptionsArray.append(subscription)
}

func pushNotificationTaskRejected() {
    let myTaskPredicate = NSPredicate(format: "member == %@", currentMemberReference)
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrganizationReference)
    let myFinishedTaskPredicate = NSPredicate(format:  "%K == %@", "status", "rejected")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myTaskPredicate, myOrgPredicate, myFinishedTaskPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    
    let notification = CKNotificationInfo()

    notification.alertBody = "Your task has been rejected. See comments."
    subscription.notificationInfo = notification
    
    memberSubscriptionsArray.append(subscription)
}

func pushNotificationNewTaskAdded() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrganizationReference)
    let taskStatusPredicate = NSPredicate(format:  "%K == %@", "status", "unassigned")
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate])
    
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    
    let notification = CKNotificationInfo()
    
    notification.alertLocalizationArgs = ["name"]
    notification.alertLocalizationKey = "'%@' task has been requested."
    subscription.notificationInfo = notification
    
    memberSubscriptionsArray.append(subscription)
}

func pushNotificationTaskAssignedToUser() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrganizationReference)
    let taskAssignedPredicate = NSPredicate(format: "member == %@", currentMemberReference)
    let taskStatusPredicate = NSPredicate(format:  "%K == %@", "status", "inProgress")
    let adminAssignedPredicate = NSPredicate(format: "lastModifiedUserRecordID == %@", (currentOrg?.creatorUserRecordID)!)
    // adminAssignedPredicate makes sure that the one modifying the task is the admin
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskAssignedPredicate, adminAssignedPredicate, taskStatusPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    
    let notification = CKNotificationInfo()

    notification.alertLocalizationArgs = ["name"]
    notification.alertLocalizationKey = "You have been assigned the task '%@'."
    subscription.notificationInfo = notification
    
    
    memberSubscriptionsArray.append(subscription)
}

func pushNotificationMemberJoined() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrganizationReference)
    let subscription = CKSubscription(recordType: "Member", predicate: myOrgPredicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
    
    let notification = CKNotificationInfo()

    notification.alertLocalizationArgs = ["name"]
    notification.alertLocalizationKey = "%@ has joined your organization."
    subscription.notificationInfo = notification
    
    adminSubscriptionsArray.append(subscription)
}

func pushNotificationTaskTaken() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrganizationReference)
    let taskStatusPredicate = NSPredicate(format: "%K == %@", "status", "inProgress")
    let memberAssignedPredicate = NSPredicate(format: "lastModifiedUserRecordID != %@", (currentOrg?.creatorUserRecordID)!)
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate, memberAssignedPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    
    let notification = CKNotificationInfo()

    notification.alertLocalizationArgs = ["name"]
    notification.alertLocalizationKey = "Task: '%@' has been taken."
    subscription.notificationInfo = notification
    
    adminSubscriptionsArray.append(subscription)
}

func pushNotificationTaskCompleted() {
    let myOrgPredicate = NSPredicate(format: "organization == %@", currentOrganizationReference)
    let taskStatusPredicate = NSPredicate(format: "%K == %@", "status", "pending")
    
    let compoundPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [myOrgPredicate, taskStatusPredicate])
    let subscription = CKSubscription(recordType: "Task", predicate: compoundPredicate, options: CKSubscriptionOptions.FiresOnRecordUpdate)
    
    let notification = CKNotificationInfo()

    notification.alertLocalizationArgs = ["name"]
    notification.alertLocalizationKey = "Task: '%@' has been sent to you for approval."
    subscription.notificationInfo = notification
    
    adminSubscriptionsArray.append(subscription)
}











