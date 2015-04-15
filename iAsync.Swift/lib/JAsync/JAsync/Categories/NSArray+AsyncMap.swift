//
//  NSArray+AsyncMap.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 28.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public func asyncWaitAllMap<Sequence: SequenceType, R>(
    sequence : Sequence,
    binder: JAsyncTypes2<Sequence.Generator.Element, R>.JAsyncBinder) -> JAsyncTypes<[R]>.JAsync
{
    let loaders = map(sequence, { (transform) -> JAsyncTypes<R>.JAsync in
        return binder(transform)
    })
    
    return groupOfAsyncsArray(loaders)
}

