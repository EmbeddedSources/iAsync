//
//  Dictionary+BlocksAdditions.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 18.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func map<R>(block : (key : Key, value : Value) -> R) -> [Key:R] {
        
        var result = [Key:R]()
        
        for (key, value) in self {
            
            result[key] = block(key: key, value: value)
        }
        
        return result
    }
    
    func forceMap<R>(block : (key : Key, value : Value) -> R?) -> [Key:R] {
        
        var result = [Key:R]()
        
        for (key, value) in self {
            
            let newValue = block(key: key, value: value)
            if let value : R = newValue {
                result[key] = value
            }
        }
        
        return result
    }
}

public func >>=<K: Hashable, V, R>(obj: [K:V], f: (K, V) -> JResult<R>) -> JResult<[K:R]> {
    
    var result: [K:R] = [K:R]()
    
    for (key, value) in obj {
        
        let newObject = f(key, value)
        
        switch newObject {
        case let .Error(e):
            return JResult.error(e)
        case let .Value(v):
            result[key] = v.value
        }
    }
    
    return JResult.value(result)
}

public func +<K: Hashable, V>(a: [K:V], b: [K:V]?) -> [K:V]
{
    if let b = b {
        
        return (a + b)!
    }
    
    return a
}

public func +<K: Hashable, V>(a: [K:V]?, b: [K:V]) -> [K:V]
{
    if let a = a {
        
        return (a + b)!
    }
    
    return b
}

public func +<K: Hashable, V>(a: [K:V]?, b: [K:V]?) -> [K:V]?
{
    if a == nil && b == nil {
        
        return nil
    }
    
    var result = [K:V]()
    
    if let a = a {
        for (key, value) in a {
            result[key] = value
        }
    }
    
    if let b = b {
        for (key, value) in b {
            result[key] = value
        }
    }
    
    return result
}
