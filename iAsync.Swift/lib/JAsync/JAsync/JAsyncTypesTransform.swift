//
//  JAsyncTypesTransform.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 04.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public enum JAsyncTypesTransform<T1, T2> {
    
    private typealias Async1 = JAsyncTypes<T1>.JAsync
    private typealias Async2 = JAsyncTypes<T2>.JAsync
    
    public typealias PackedType = (T1?, T2?)
    
    private typealias PackedAsync = JAsyncTypes<PackedType>.JAsync
    
    public typealias AsyncTransformer = (PackedAsync) -> PackedAsync
    
    public static func transformLoadersType1(async: Async1, transformer: AsyncTransformer) -> Async1 {
        
        let packedLoader = bindSequenceOfAsyncs(async, { result -> PackedAsync in
            return asyncWithResult((result, nil))
        })
        let transformedLoader = transformer(packedLoader)
        return bindSequenceOfAsyncs(transformedLoader, { result -> Async1 in
            return asyncWithResult(result.0!)
        })
    }
    
    public static func transformLoadersType2(async: Async2, transformer: AsyncTransformer) -> Async2 {
        
        let packedLoader = bindSequenceOfAsyncs(async, { result -> PackedAsync in
            return asyncWithResult((nil, result))
        })
        let transformedLoader = transformer(packedLoader)
        return bindSequenceOfAsyncs(transformedLoader, { result -> Async2 in
            return asyncWithResult(result.1!)
        })
    }
}
