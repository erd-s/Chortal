//
//  ErrorHandler.swift
//  Chortal
//
//  Created by Christopher Erdos on 3/2/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import Foundation
import CloudKit



//    CKErrorInternalError           = 1,  /* CloudKit.framework encountered an error.  This is a non-recoverable error. */
//    CKErrorPartialFailure          = 2,  /* Some items failed, but the operation succeeded overall */
//    CKErrorNetworkUnavailable      = 3,  /* Network not available */
//    CKErrorNetworkFailure          = 4,  /* Network error (available but CFNetwork gave us an error) */
//    CKErrorBadContainer            = 5,  /* Un-provisioned or unauthorized container. Try provisioning the container before retrying the operation. */
//    CKErrorServiceUnavailable      = 6,  /* Service unavailable */
//    CKErrorRequestRateLimited      = 7,  /* Client is being rate limited */
//    CKErrorMissingEntitlement      = 8,  /* Missing entitlement */
//    CKErrorNotAuthenticated        = 9,  /* Not authenticated (writing without being logged in, no user record) */
//    CKErrorPermissionFailure       = 10, /* Access failure (save or fetch) */
//    CKErrorUnknownItem             = 11, /* Record does not exist */
//    CKErrorInvalidArguments        = 12, /* Bad client request (bad record graph, malformed predicate) */
//    CKErrorResultsTruncated        = 13, /* Query results were truncated by the server */
//    CKErrorServerRecordChanged     = 14, /* The record was rejected because the version on the server was different */
//    CKErrorServerRejectedRequest   = 15, /* The server rejected this request.  This is a non-recoverable error */
//    CKErrorAssetFileNotFound       = 16, /* Asset file was not found */
//    CKErrorAssetFileModified       = 17, /* Asset file content was modified while being saved */
//    CKErrorIncompatibleVersion     = 18, /* App version is less than the minimum allowed version */
//    CKErrorConstraintViolation     = 19, /* The server rejected the request because there was a conflict with a unique field. */
//    CKErrorOperationCancelled      = 20, /* A CKOperation was explicitly cancelled */
//    CKErrorChangeTokenExpired      = 21, /* The previousServerChangeToken value is too old and the client must re-sync from scratch */
//    CKErrorBatchRequestFailed      = 22, /* One of the items in this batch operation failed in a zone with atomic updates, so the entire batch was rejected. */
//    CKErrorZoneBusy                = 23, /* The server is too busy to handle this zone operation. Try the operation again in a few seconds. */
//    CKErrorBadDatabase             = 24, /* Operation could not be completed on the given database. Likely caused by attempting to modify zones in the public database. */
//    CKErrorQuotaExceeded           = 25, /* Saving a record would exceed quota */
//    CKErrorZoneNotFound            = 26, /* The specified zone does not exist on the server */
//    CKErrorLimitExceeded           = 27, /* The request to the server was too large. Retry this request as a smaller batch. */
//    CKErrorUserDeletedZone         = 28, /* The user deleted this zone through the settings UI. Your client should either remove its local data or prompt the user before attempting to re-upload any data to this zone. */


    
    


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

    func presentErrorMessage() -> UIViewController {
        switch self {
/* restart app */  case .InternalError, .InvalidArguments, .IncompatibleVersion, .BadDatabase, .BadContainer, .ServerRejectedRequest, .UnknownItem, .OperationCancelled, .UserDeletedZone
/* continue */     case .PartialFailure
/* retry later */  case .NetworkFailure, .NetworkUnavailable, .ServiceUnavailable, .ZoneBusy, .LimitExceeded
        
            
        }
}
}
    
    
    
    
    
    
    
    
    
    
    
    
    