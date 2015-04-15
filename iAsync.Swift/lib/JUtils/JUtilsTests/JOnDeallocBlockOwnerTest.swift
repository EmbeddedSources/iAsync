//
//  JOnDeallocBlockOwnerTest.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 14.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JUtils

class JOnDeallocBlockOwnerTest: XCTestCase {
    
    func testOnDeallocBlockOwnerBehavior() {
        
        var blockCalled = false
        var blockContextDeallocated = false
        
        autoreleasepool {
            
            let blockContext: NSObject? = NSObject()
            blockContext!.addOnDeallocBlock({ () -> () in
                blockContextDeallocated = true
            })
            
            let owner = JOnDeallocBlockOwner(block: {
                if blockContext != nil {
                    blockCalled = true
                }
            })
            
            XCTAssertFalse(blockContextDeallocated, "Block context should not be dealloced")
            XCTAssertFalse(blockCalled, "block should not be called here")
            XCTAssertNotNil(owner, "holr object")
        }
        
        XCTAssertTrue(blockContextDeallocated, "Block context should be dealloced")
        XCTAssertTrue(blockCalled, "block should be called here")
    }
    
    func testDoNotCallOnDeallocBlockAfterRemoveIt() {
        
        var blockCalled = false
        
        autoreleasepool {
            let owner = NSObject()
            
            let onDeallocBlockHolder = JOnDeallocBlockOwner(block: {
                blockCalled = true
            })
            
            owner.addOnDeallocBlockHolder(onDeallocBlockHolder)
            
            XCTAssertFalse(blockCalled)
            
            owner.removeOnDeallocBlockHolder(onDeallocBlockHolder)
        }
        
        XCTAssertFalse(blockCalled)
    }
}
