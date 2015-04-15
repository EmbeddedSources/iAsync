//
//  JJsonValueTests.swift
//  JJsonTools
//
//  Created by Vladimir Gorbenko on 04.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation
import XCTest

import JUtils

class TestJsonUser : Printable {
    
    let firstName: String
    let lastName : String
    let emptyField: Dictionary<String, String>
    let street: String
    let city  : String
    
    init(
        firstName: String,
        lastName: String,
        emptyField: Dictionary<String, String>,
        street: String,
        city: String)
    {
        self.firstName  = firstName
        self.lastName   = lastName
        self.emptyField = emptyField
        self.street     = street
        self.city       = city
    }
    
    var description: String {
        return "firstName: \(firstName), lastName: \(lastName)"
    }
}

extension TestJsonUser: Equatable {}

func ==(lhs: TestJsonUser, rhs: TestJsonUser) -> Bool {
    
    let result = (
           (lhs.firstName  == rhs.firstName )
        && (lhs.lastName   == rhs.lastName  )
        && (lhs.emptyField == rhs.emptyField)
        && (lhs.street     == rhs.street    )
        && (lhs.city       == rhs.city      )
    )
    return result
}

class JJsonValueTests : XCTestCase {
    
    func testNormalParse() {
        
        let jsonFirstName = "Иван"
        let jsonLastName  = "Иванов"
        let jsonStreet = "Московское ш., 101, кв.101"
        let jsonCity   = "Иванов"
        let json = "{\"firstName\": \"\(jsonFirstName)\",\"lastName\": \"\(jsonLastName)\",\"address\": {\"streetAddress\": \"\(jsonStreet)\",\"city\": \"\(jsonCity)\"},\"phoneNumbers\": [\"812 123-1234\",\"916 123-4567\"], \"emptyField\": null, \"el\": {\"subEl\": [1, 2, 3]}}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let jsonObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(
            data,
            options:nil,
            error:nil)
        
        XCTAssertNotNil(jsonObject)
        
        let jsonValueRes = JJsonValue.create(jsonObject)
        
        let result = jsonValueRes >>= { json -> JResult<TestJsonUser> in
            
            let firstName = json.string("firstName")
            let lastName  = json.string("lastName" )
            
            let address = json.dict("address") >>= { $0 >>= { $0.1.string } }
            
            let subElements = json.array("el" </> "subEl") >>= { $0 >>= { $0.number >>= { JResult.value(Int($0)) } } }
            
            switch subElements {
            case let .Value(v):
                
                let expectedResult = [1, 2, 3]
                XCTAssertEqual(expectedResult.count, v.value.count)
                
                for i in 0..<expectedResult.count {
                    XCTAssertEqual(expectedResult[i], v.value[i])
                }
            default:
                XCTFail()
            }
            
            return json["address"] >>= { ($0.string("streetAddress"), $0.string("city")) >>= { (street, city) -> JResult<TestJsonUser> in
                
                return ((firstName, lastName, address) >>= { (firstName, lastName, address) -> JResult<TestJsonUser> in
                    
                    let res = TestJsonUser(firstName: firstName, lastName: lastName, emptyField: [:], street: street, city: city)
                    return JResult.value(res)
                })
            }}
        }
        
        switch result {
        case let .Value(v):
            
            let expectedResult = TestJsonUser(firstName: jsonFirstName, lastName: jsonLastName, emptyField: [:], street: jsonStreet, city: jsonCity)
            XCTAssertEqual(expectedResult, v.value)
            return
        default:
            XCTFail()
        }
        
        XCTFail()
    }
    
    func testErrorNoDataForKey() {
        
        let jsonFirstName = "Иван"
        let jsonLastName  = "Иванов"
        let jsonStreet = "Московское ш., 101, кв.101"
        let jsonCity   = "Иванов"
        let json = "{\"firstName\": \"\(jsonFirstName)\",\"lastName\": \"\(jsonLastName)\",\"address\": {\"streetAddress\": \"\(jsonStreet)\",\"city\": \"\(jsonCity)\"},\"phoneNumbers\": [\"812 123-1234\",\"916 123-4567\"], \"emptyField\": null, \"el\": {\"subEl\": [1, 2, 3]}}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let jsonObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(
            data,
            options:nil,
            error:nil)
        
        XCTAssertNotNil(jsonObject)
        
        let jsonValueRes = JJsonValue.create(jsonObject)
        
        let result = jsonValueRes >>= { $0.string("firstName1") }
        
        switch result {
        case let .Error(error):
            
            XCTAssertNotNil(error)
            
            let logDescription = error.errorLogDescription()
            //XCTAssertEqual("JNoDataForKeyInJsonObjectError : J_NO_DATA_FOR_KEY_IN_JSON_OBJECT jsonValue:Optional(JJsonObject([el: JJsonObject([subEl: JJsonArray([JJsonNumber(1.0), JJsonNumber(2.0), JJsonNumber(3.0)])]), lastName: JJsonString(Иванов), address: JJsonObject([streetAddress: JJsonString(Московское ш., 101, кв.101), city: JJsonString(Иванов)]), emptyField: JJsonNull(), firstName: JJsonString(Иван), phoneNumbers: JJsonArray([JJsonString(812 123-1234), JJsonString(916 123-4567)])])) key:Optional(\"firstName1\")", logDescription)
            return
        default:
            
            XCTFail()
        }
        
        XCTFail()
    }
}
