//
//  JSimpleBlockHolderTest.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 14.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JUtils

class JSimpleBlockHolderTest: XCTestCase {
    
    func testSimpleBlockHolderBehavior()  {
        
        weak var weakHolder: JSimpleBlockHolder?
        
        autoreleasepool {
            let strongHolder: JSimpleBlockHolder? = JSimpleBlockHolder()
            weakHolder = strongHolder
            
            var blockContextDeallocated = false
            var performBlockCount = 0
            
            autoreleasepool {
                let blockContext: NSObject? = NSObject()
                blockContext!.addOnDeallocBlock({
                    blockContextDeallocated = true
                })
                
                strongHolder!.simpleBlock = {
                    if blockContext != nil && strongHolder != nil {
                        ++performBlockCount
                    }
                }
                
                strongHolder!.onceSimpleBlock()()
                strongHolder!.onceSimpleBlock()()
            }
            
            XCTAssertTrue (blockContextDeallocated, "Block context should be dealloced")
            XCTAssertEqual(1, performBlockCount   , "Block was called once")
            
            let block = strongHolder?.simpleBlock
            XCTAssertTrue(block == nil)
        }
        
        XCTAssertNil(weakHolder, "Block holder should be dealloced")
    }
}
