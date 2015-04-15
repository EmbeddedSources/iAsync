//
//  NSObject+OwnershipsTest.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 14.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

class NSObject_OwnershipsTest: XCTestCase {
    
    func testObjectOwnershipsExtension() {
        
        weak var ownedDeallocated: NSObject?
        
        { () -> () in
            let owner = NSObject()
            
            { () -> () in
                let owned = NSObject()
                ownedDeallocated = owned
                owner.addOwnedObject(owned)
            }()
            
            XCTAssertNotNil(ownedDeallocated, "Owned should not be dealloced")
        }()
        
        XCTAssertNil(ownedDeallocated, "Owned should be dealloced")
    }
}
