//
//  HashableDictionary.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 02.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public struct HashableDictionary<Key : Hashable, Value: Equatable> : Hashable, Printable {
    
    private var dict = [Key:Value]()
    
    public var hashValue: Int {
        return dict.count
    }
    
    public init(dict: [Key:Value]) {
        
        self.dict = dict
    }
    
    public init() {
    
        self.init(dict: [Key:Value]())
    }
    
    public var description: String {
        return "JUtils.HashableDictionary: \(dict)"
    }
}

public func ==<Key : Hashable, Value: Equatable>(lhs: HashableDictionary<Key, Value>, rhs: HashableDictionary<Key, Value>) -> Bool {
    
    return lhs.dict == rhs.dict
}
