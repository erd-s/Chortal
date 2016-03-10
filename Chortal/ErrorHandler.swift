//
//  ErrorHandler.swift
//  Chortal
//
//  Created by Christopher Erdos on 3/2/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import Foundation
import CloudKit


func checkError(error: NSError, view: UIViewController){
    let rawValue = error.code
    let informationToPresent = HandleError(rawValue: rawValue)?.presentErrorMessage(view, error: error)
    view.errorAlert(informationToPresent!.title, message:  informationToPresent!.message)
}

enum HandleError: Int {
    case InternalError
    case PartialFailure
    case NetworkUnavailable
    case NetworkFailure
    case BadContainer
    case ServiceUnavailable
    case RequestRateLimited
    case MissingEntitlement
    case NotAuthenticated
    case PermissionFailure
    case UnknownItem
    case InvalidArguments
    case ResultsTruncated
    case ServerRecordChanged
    case ServerRejectedRequest
    case AssetFileNotFound
    case AssetFileModified
    case IncompatibleVersion
    case ConstraintViolation
    case OperationCancelled
    case ChangeTokenExpired
    case BatchRequestFailed
    case ZoneBusy
    case BadDatabase
    case QuotaExceeded
    case ZoneNotFound
    case LimitExceeded
    case UserDeletedZone
    
    func presentErrorMessage(view: UIViewController, error: NSError) -> (title: String, message: String) {
        let retryAfter = error.userInfo[CKErrorRetryAfterKey] as? NSTimeInterval
        let retryAfterString = "\(retryAfter) seconds"
        
        switch self {
        case
        .InternalError,
        .InvalidArguments,
        .IncompatibleVersion,
        .BadDatabase,
        .BadContainer,
        .ServerRejectedRequest,
        .UnknownItem,
        .OperationCancelled,
        .UserDeletedZone,
        .MissingEntitlement,
        .ChangeTokenExpired,
        .ZoneNotFound:
            return (title: "Error", message: "Please restart the app. Error description: \(error.localizedDescription).")
            
        case
        .PartialFailure,
        .ResultsTruncated:
            return (title: "Error", message: "Error saving all records. Please try again. Error description: \(error.localizedDescription).")
            
        case
        .NetworkFailure,
        .NetworkUnavailable:
            return (title: "Error", message: "Please check your network connection and try again.")
        
        case
        .ServiceUnavailable,
        .ZoneBusy,
        .LimitExceeded,
        .RequestRateLimited,
        .AssetFileNotFound,
        .AssetFileModified,
        .ConstraintViolation,
        .ServerRecordChanged,
        .BatchRequestFailed,
        .QuotaExceeded:
            return (title: "Error", message: "Please try again in \(retryAfterString) seconds.")
            
        case
        .NotAuthenticated,
        .PermissionFailure:
            return (title: "Error", message: "Please log in to iCloud and try again.")
        }
    }
}












    