//
//  JContainersHelperBlocks.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public typealias JProducerBlock = (index : Int) -> AnyObject

public typealias JOptionProducerBlock = (index : Int) -> AnyObject?

public typealias JOptionMappingBlock = (object : AnyObject) -> AnyObject?

public typealias JMappingWithErrorBlock = (object : AnyObject, outError : NSErrorPointer) -> AnyObject?

public typealias JMappingWithErrorAndIndexBlock = (object : AnyObject, index : Int, outError : NSErrorPointer) -> AnyObject?

public typealias JFlattenBlock = (object : AnyObject) -> NSArray

public typealias JTransformBlock = (firstObject : AnyObject, secondObject : AnyObject) -> ()

public typealias JElementIndexBlock = (object : AnyObject) -> Int
