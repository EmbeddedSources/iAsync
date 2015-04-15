//
//  JMutableAssignArrayTest.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 14.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JUtils

class JMutableAssignArrayTest: XCTestCase {
    
    func testMutableAssignArrayAssignIssue() {
        
        var array: JMutableAssignArray<NSObject>!
        
        { () -> () in
            
            weak var weakTarget: NSObject?
            
            { () -> () in
                let target = NSObject()
                
                weakTarget = target
                
                array = JMutableAssignArray()
                array.append(target)
                
                XCTAssertTrue(1 == array.count, "Contains 1 object")
            }()
            
            XCTAssertNil(weakTarget, "Target should be dealloced")
        }()
        
        XCTAssertEqual(0, array!.count, "Empty array")
    }
    
    func testMutableAssignArrayFirstRelease()
    {
        weak var weakArray: JMutableAssignArray<NSObject>?
        
        { () -> () in
            
            let array = JMutableAssignArray<NSObject>()
            
            weakArray = array
            
            let target = NSObject()
            array.append(target)
        }()
        
        XCTAssertNil(weakArray, "Target should be dealloced")
    }
    
    func testLastObject()
    {
        let array = JMutableAssignArray<NSObject>()
        
        let object = NSObject()
        array.append(object)
        
        XCTAssertEqual(object, array.last!, "Target should be deallocated")
    }
    
    func testContainsObject()
    {
        autoreleasepool {
            
            var array = JMutableAssignArray<NSObject>()
            
            weak var object1Ptr: NSObject?
            
            var onDeallocBlockCalled = false
            
            { () -> () in
                
                array = JMutableAssignArray<NSObject>()
                
                let object1 = NSObject()
                object1Ptr = object1
                
                object1.addOnDeallocBlock({
                    onDeallocBlockCalled = true
                })
                
                let object2 = NSObject()
                array.append(object1)
                
                XCTAssertTrue (array.containsObject(object1), "Array contains object1")
                XCTAssertFalse(array.containsObject(object2), "Array no contains object2")
            }()
            
            XCTAssertTrue(onDeallocBlockCalled, "EonDeallocBlock called")
            XCTAssertTrue(0 == array.count, "Empty array")
            XCTAssertNil(object1Ptr, "Empty array")
        }
    }
}
