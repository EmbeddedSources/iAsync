//
//  JCacheDB.swift
//  JRestKit
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public protocol JCacheDB {
    
    func dataForKey(key: String) -> NSData?
    
    func dataAndLastUpdateDateForKey(key: String) -> (NSData, NSDate)?
    
    func setData(data: NSData?, forKey key: String)
    
    func removeRecordsForKey(key: String)
    
    func removeAllRecordsWithCallback(callback: JSimpleBlock?)
}
