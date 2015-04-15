//
//  JAssignProxyTest.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 14.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JUtils

class ProxyTargetTest : NSObject, NSObjectProtocol {}

class JAssignProxyTest: XCTestCase {
    
    func testAssignProxyDealloc() {
        
        var proxy: JAssignObjectHolder<ProxyTargetTest>?
        var targetDeallocated = false
        
        { () -> () in
            let target = ProxyTargetTest()
            target.addOnDeallocBlock({
                targetDeallocated = true
            })
            
            let ptr = Unmanaged<ProxyTargetTest>.passUnretained(target)
            proxy = JAssignObjectHolder(targetPtr: ptr)
        }()
        
        XCTAssertTrue(targetDeallocated, "Target should be dealloced")
    }
}
