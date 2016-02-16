//
//  CloudKitAccess.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitAccess {
    var container: CKContainer
    var privateDatabase: CKDatabase
    var publicDatabase: CKDatabase
    
    init() {
        container = CKContainer.defaultContainer()
        privateDatabase = container.privateCloudDatabase
        publicDatabase = container.publicCloudDatabase
    }
    
    
    func newRecord() {
        let timestamp = String(NSDate.timeIntervalSinceReferenceDate())
        let timestampParts = timestamp.componentsSeparatedByString(".")
        let uid = timestampParts[0]
        
        let record = CKRecord(recordType: "Users")
        record.setObject(uid, forKey: "uid")
        
        publicDatabase.saveRecord(record) { (record, error) -> Void in
            if error != nil {
                print(error)
            }
        }
    }
}