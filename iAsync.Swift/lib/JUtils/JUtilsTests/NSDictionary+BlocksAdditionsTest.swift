//
//  NSDictionary+BlocksAdditionsTest.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 15.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JUtils

class NSDictionary_BlocksAdditionsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMapMethod() {
        
        let dict = [
            "1" : 1,
            "2" : 2,
            "3" : 3,
        ]
        
        let result = (dict as NSDictionary).map({ (key: AnyObject, object: AnyObject) -> AnyObject in
            
            let objectNum = object as NSNumber
            let keyStr = key as String
            return objectNum.integerValue * key.integerValue
        })
        
        XCTAssertEqual(result.count,  3)
        XCTAssertFalse(result is NSMutableDictionary)
        XCTAssertTrue (result is NSDictionary)
        
        XCTAssertEqual(1, result.objectForKey("1") as NSObject)
        XCTAssertEqual(4, result.objectForKey("2") as NSObject)
        XCTAssertEqual(9, result.objectForKey("3") as NSObject)
    }
    
    func testEachMethod() {
        
        let dict = [
            "1" : 1,
            "2" : 2,
            "3" : 3,
        ]
        
        let keys    = NSMutableArray()
        let objects = NSMutableArray()
        
        for (key, value) in dict {
            keys   .addObject(key  )
            objects.addObject(value)
        }
        
        XCTAssertEqual(3, keys.count)
        
        for key : AnyObject in (dict as NSDictionary).allKeys {
            XCTAssertTrue(keys.containsObject(key))
        }
        
        XCTAssertEqual(3, objects.count)
        
        for value : AnyObject in (dict as NSDictionary).allValues {
            XCTAssertTrue(objects.containsObject(value))
        }
    }
    
    func testCountMethod() {
        
        let dict = [
            "1" : 1,
            "2" : 2,
            "3" : 3,
        ]
        
        let count = (dict as NSDictionary).count({ (key : AnyObject, object : AnyObject) -> Bool in
            
            let objectNum = object as Int
            let keyStr = key as String
            return 2 == objectNum && "2" == keyStr
        })
        
        XCTAssertEqual(count, 1)
    }
    
    func testKeyMethod() {
        
        let dict = [
            "one"   : 1,
            "two"   : 2,
            "three" : 3,
        ]
        
        let result = (dict as NSDictionary).mapKey({ (key : AnyObject, object : AnyObject) -> AnyObject in
            
            let objectNum = object as NSNumber
            let keyStr = key as NSString
            return keyStr.uppercaseString.stringByAppendingString(objectNum.stringValue)
        })
        
        XCTAssertEqual(result.count, 3)
        XCTAssertFalse(result is NSMutableDictionary)
        XCTAssertTrue (result is NSDictionary)
        
        XCTAssertEqual(1, result.objectForKey("ONE1") as NSObject)
        XCTAssertEqual(2, result.objectForKey("TWO2") as NSObject)
        XCTAssertEqual(3, result.objectForKey("THREE3") as NSObject)
    }
    
    func testMapAndErrorMethodWithoutError() {
        
        let dict = [
            "1" : 1,
            "2" : 2,
            "3" : 3,
        ]
        
        var error: NSError?
        
        let block = { (key : AnyObject, object : AnyObject, outError : NSErrorPointer) -> AnyObject? in
            
            XCTAssertTrue(outError != nil)
            let num = object.unsignedIntegerValue
            return num * key.integerValue
        }
        
        let result = (dict as NSDictionary).map(block, outError:&error)
        
        XCTAssertNil(error)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 3)
        XCTAssertFalse(result! is NSMutableDictionary)
        XCTAssertTrue (result! is NSDictionary)
        
        XCTAssertEqual(1, result!.objectForKey("1") as NSObject)
        XCTAssertEqual(4, result!.objectForKey("2") as NSObject)
        XCTAssertEqual(9, result!.objectForKey("3") as NSObject)
    }
    
    func testMapAndErrorMethodWithError() {
        
        let dict = [
            "1" : 1,
            "2" : 2,
            "3" : 3,
        ]
        
        var error: NSError?
        
        let errorForMap = JError(description : "test error")
        
        let result = (dict as NSDictionary).map({ (key : AnyObject, object : AnyObject, outError : NSErrorPointer) -> AnyObject? in
            
            XCTAssertTrue(outError != nil)
            let num = object.unsignedIntegerValue
            if (num == 3) {
                outError.memory = errorForMap
                return nil
            }
            return num * key.integerValue
            }, outError:&error)
        
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        
        XCTAssertTrue(errorForMap === error)
    }
    
    func testAny() {
        
        let arr = ["a", "b", "c"]
        
        XCTAssertTrue(any(arr, { (str : String) -> Bool in
            
            return str == "a"
        }))
        
        XCTAssertTrue(any(arr, { (str : String) -> Bool in
            
            return str == "b"
        }))
        
        XCTAssertTrue(any(arr, { (str : String) -> Bool in
            
            return str == "c"
        }))
        
        XCTAssertFalse(any(arr, { (str : String) -> Bool in
            
            return str == "d"
        }))
    }
    
    func testAllMethod() {
        
        let arr = ["a", "b", "c"]
        
        XCTAssertTrue(all(arr, { (str : String) -> Bool in
            
            return str.utf16Count == 1
        }))
        
        XCTAssertFalse(all(arr, { (str : String) -> Bool in
            
            return str == "a" || str == "b"
        }))
    }
}
