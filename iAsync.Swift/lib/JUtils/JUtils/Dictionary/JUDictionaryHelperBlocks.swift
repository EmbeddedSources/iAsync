//
//  JUDictionaryHelperBlocks.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//TODO make it template
public typealias JDictMappingBlock = (key : AnyObject, object : AnyObject) -> AnyObject

//TODO make it template
public typealias JDictOptionMappingBlock = (key : AnyObject, object : AnyObject) -> AnyObject?

//TODO make it template
public typealias JDictMappingWithErrorBlock = (key : AnyObject, object : AnyObject, outError : NSErrorPointer) -> AnyObject?

//TODO make it template
public typealias JDictPredicateBlock = (key : AnyObject, object : AnyObject) -> Bool
