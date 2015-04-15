//
//  JJsonValueError.swift
//  JJsonTools
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JJsonValueError : JJsonToolsError {}

public class JInvalidRawJsonObjectError : JJsonValueError {
    
    var rootJsonObject: AnyObject?
    var invalidJsonObject: AnyObject?
    
    init() {
        super.init(description: "J_INVALID_JSON_OBJECT")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var errorLogDescription: String {
        return "\(self.dynamicType) : \(localizedDescription) invalidJsonObject:\(invalidJsonObject) rootJsonObject:\(rootJsonObject)"
    }
}

public class JNoDataForKeyInJsonObjectError : JJsonValueError {
    
    var jsonValue: JJsonValue?
    var key: String?
    
    init() {
        super.init(description: "J_NO_DATA_FOR_KEY_IN_JSON_OBJECT")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var errorLogDescription: String {
        return "\(self.dynamicType) : \(localizedDescription) jsonValue:\(jsonValue) key:\(key)"
    }
}

public class JNoDataForPathInJsonObjectError : JJsonValueError {
    
    var jsonValue: JJsonValue?
    var path: JPath?
    var key: String?
    
    init() {
        super.init(description: "J_NO_DATA_FOR_PATH_IN_JSON_OBJECT")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var errorLogDescription: String {
        let result = "\(self.dynamicType) : \(localizedDescription) jsonValue:\(jsonValue) path:\(path) key:\(key)"
        return result
    }
}

public class JValidationTypeJsonObjectError : JJsonValueError {
    
    var expectedType: String?
    var jsonValue: JJsonValue?
    
    init() {
        super.init(description: "J_VALIDATION_TYPE_JSON_OBJECT")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var errorLogDescription: String {
        return "\(self.dynamicType) : \(localizedDescription) jsonValue:\(jsonValue) expectedType:\(expectedType)"
    }
}
