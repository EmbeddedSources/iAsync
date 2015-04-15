//
//  SequenceType+Extensions.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 01.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public func firstMatch<Sequence: SequenceType>(
    sequence : Sequence,
    @noescape predicate: (value: Sequence.Generator.Element) -> Bool) -> Sequence.Generator.Element? {
    
    for object in sequence {
        if predicate(value: object) {
            return object
        }
    }
    return nil
}

public func indexOf<Sequence: SequenceType>(
    sequence: Sequence,
    @noescape predicate: (value: Sequence.Generator.Element) -> Bool) -> Int
{
    for (index, element) in enumerate(sequence) {
        if predicate(value: element) {
            return index
        }
    }
    return Int.max
}

public func any<Sequence: SequenceType>(sequence: Sequence, @noescape predicate : (Sequence.Generator.Element) -> Bool) -> Bool {
    let object = firstMatch(sequence, predicate)
    return object != nil
}

public func all<Sequence: SequenceType>(sequence: Sequence, @noescape predicate : (Sequence.Generator.Element) -> Bool) -> Bool {
    return !any(sequence) { (object: Sequence.Generator.Element) -> Bool in
        return !predicate(object)
    }
}

public func >>=<Sequence: SequenceType, R>(obj: Sequence, f: Sequence.Generator.Element -> JResult<R>) -> JResult<[R]> {
    
    var result = [R]()
    
    for object in obj {
        
        let newObject = f(object)
        
        switch newObject {
        case let .Error(e):
            return JResult.error(e)
        case let .Value(v):
            result.append(v.value)
        }
    }
    
    return JResult.value(result)
}
