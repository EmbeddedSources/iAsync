//
//  JObjcUtilsBlockDefinitions.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 03.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public typealias JObjcPredicateBlock = (object: AnyObject) -> Bool

public typealias JObjcAnalyzer = (object: AnyObject, outError: NSErrorPointer) -> AnyObject?

public typealias JObjcMappingBlock = (object : AnyObject) -> AnyObject
