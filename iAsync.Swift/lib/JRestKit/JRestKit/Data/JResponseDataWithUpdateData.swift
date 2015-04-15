//
//  JResponseDataWithUpdateData.swift
//  JRestKit
//
//  Created by Vladimir Gorbenko on 13.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//TODO remove inheritence from NSObject
public class JResponseDataWithUpdateData : NSObject, JRestKitCachedData {
    
    public let data: NSData
    public let updateDate: NSDate?
    
    public init(data: NSData, updateDate: NSDate?) {
        
        self.data       = data
        self.updateDate = updateDate
    }
}
