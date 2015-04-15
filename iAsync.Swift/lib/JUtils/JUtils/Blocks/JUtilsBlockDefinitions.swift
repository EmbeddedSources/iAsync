//
//  JUtilsBlockDefinitions.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public typealias JSimpleBlock = () -> ()

public enum JUtilsBlockDefinitions<T> {
    
    public typealias JPredicateBlock = (object: T) -> Bool
}

public enum JUtilsBlockDefinitions2<T1, T2> {
    
    public typealias JMappingBlock = (object: T1) -> T2
    
    public typealias JAnalyzer = (object: T1) -> JResult<T2>
}

//TODO make it template
public typealias JPredicateWithIndexBlock = (object: AnyObject, index: Int) -> Bool
