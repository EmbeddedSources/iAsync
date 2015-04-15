//
//  JMutableAssignDictionaryTest.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 15.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JUtils

class JMutableAssignDictionaryTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMutableAssignDictionaryAssignIssue() {
        var dict1: JMutableAssignDictionary<String, NSObject>?
        var dict2: JMutableAssignDictionary<String, NSObject>?
        var targetDeallocated = false
        
        { () -> () in
            let target = NSObject()
            
            target.addOnDeallocBlock({
                targetDeallocated = true
            })
            
            dict1 = JMutableAssignDictionary<String, NSObject>()
            dict1!["1"] = target
            
            dict2 = JMutableAssignDictionary<String, NSObject>()
            dict2!["1"] = target
            dict2!["2"] = target
            
            XCTAssertEqual(1, dict1!.count, "Contains 1 object")
            XCTAssertEqual(2, dict2!.count, "Contains 1 object")
        }()
        
        XCTAssertTrue(targetDeallocated, "Target should be dealloced")
        XCTAssertEqual(0, dict1!.count, "Empty array")
        XCTAssertEqual(0, dict2!.count, "Empty array")
    }
    
    func testMutableAssignDictionaryFirstRelease() {
        
        let target = NSObject()
        
        weak var weakDict1: JMutableAssignDictionary<String, NSObject>?
        weak var weakDict2: JMutableAssignDictionary<String, NSObject>?
        
        autoreleasepool {
            let dict1 = JMutableAssignDictionary<String, NSObject>()
            weakDict1 = dict1
            
            dict1["1"] = target
            
            let dict2 = JMutableAssignDictionary<String, NSObject>()
            weakDict2 = dict2
            
            dict2["2"] = target
        }
        
        XCTAssertTrue(weakDict1 == nil, "Target should be dealloced")
        XCTAssertTrue(weakDict2 == nil, "Target should be dealloced")
    }
    
    func testObjectForKey() {
        
        autoreleasepool {
            let dict = JMutableAssignDictionary<String, NSObject>()
            
            var targetDeallocated = false
            autoreleasepool {
                let object1 = NSObject()
                let object2 = NSObject()
                
                object1.addOnDeallocBlock({
                    targetDeallocated = true
                })
                
                dict["1"] = object1
                dict["2"] = object2
                
                XCTAssertEqual(dict["1"]!, object1, "Dict contains object_")
                XCTAssertEqual(dict["2"]!, object2, "Dict contains object_")
                XCTAssertNil(dict["3"], "Dict no contains object for key \"2\"")
                
                var count = 0
                
                for (key, value) in dict.dict {
                    
                    switch key {
                    case "1":
                        XCTAssertEqual(value, object1)
                        ++count
                    case "2":
                        XCTAssertEqual(value, object2)
                        ++count
                    default:
                        XCTFail("should not be reached")
                    }
                }
                
                XCTAssertEqual(count, 2, "Dict no contains object for key \"2\"")
            }
            
            XCTAssertTrue(targetDeallocated, "Target should be dealloced")
            XCTAssertEqual(0, dict.count, "Empty dict")
        }
    }
    
    func testReplaceObjectInDict()
    {
        let dict = JMutableAssignDictionary<String, NSObject>()
        
        autoreleasepool {
            var replacedObjectDealloced = false
            var object: NSObject?
            
            autoreleasepool {
                let replacedObject = NSObject()
                replacedObject.addOnDeallocBlock({
                    replacedObjectDealloced = true
                })
                
                object = NSObject()
                
                dict["1"] = replacedObject
                
                XCTAssertEqual(dict["1"]!, replacedObject, "Dict contains object_")
                XCTAssertNil(dict["2"], "Dict no contains object for key \"2\"")
                
                dict["1"] = object!
                XCTAssertEqual(dict["1"]!, object!, "Dict contains object_")
            }
            
            XCTAssertTrue(replacedObjectDealloced)
            
            let currentObject = dict["1"]!
            XCTAssertEqual(currentObject, object!)
        }
        
        XCTAssertTrue(0 == dict.count, "Empty dict")
    }
    
    func testMapMethod()
    {
        let dict = JMutableAssignDictionary<String, NSNumber>()
        
        dict["1"] = 1
        dict["2"] = 2
        dict["3"] = 3
        
        let result = dict.map({ (key: String, number: NSNumber) -> NSNumber in
            
            return key.toInt()! * number.integerValue
        })
        
        XCTAssertEqual(result.count, 3)
        //TODO fix - XCTAssertFalse(result.bridgeToObjectiveC().isKindOfClass(NSMutableDictionary))
        //TODO XCTAssertTrue(result.isKindOfClass(NSDictionary))
        
        let testResDict: Dictionary<String, Int> = result as Dictionary<String, Int>
        
        XCTAssertEqual(1, testResDict["1"]!)
        XCTAssertEqual(4, testResDict["2"]!)
        XCTAssertEqual(9, testResDict["3"]!)
    }
    
    func testEnumerateKeysAndObjectsUsingBlock()
    {
        let patternDict = [
            "1" : 1,
            "2" : 2,
            "3" : 3,
        ]
        
        let dict = JMutableAssignDictionary<String, NSObject>()
        
        for (key, val) in patternDict {
            dict[key] = val
        }
        
        var count = 0
        let resultDict = NSMutableDictionary()
        
        (dict.dict as NSDictionary).enumerateKeysAndObjectsUsingBlock({ (key: AnyObject!, obj: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> () in
            ++count
            resultDict.setObject(obj, forKey: key as NSCopying)
            let value: NSNumber! = patternDict[key as String]
            XCTAssertEqual(value, obj as NSNumber)
        })
        
        XCTAssertEqual(count, 3)
        XCTAssertEqual(resultDict, patternDict)
        
        count = 0
        
        (dict.dict as NSDictionary).enumerateKeysAndObjectsUsingBlock({
            (key: AnyObject!, obj: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> () in
            
            ++count
            if count == 2 && stop != nil {
                stop.memory = true
            }
        })
        
        XCTAssertEqual(count, 2)
    }
}
