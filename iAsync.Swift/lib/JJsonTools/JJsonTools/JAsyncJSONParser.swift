//
//  JAsyncJSONParser.swift
//  JJsonTools
//
//  Created by Vladimir Gorbenko on 26.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils

//TODO should returns JJsonValue
//TODO AnyObject should be Printable
func jsonObjectWithData(data: NSData, context: AnyObject?) -> JResult<AnyObject> {
    
    var jsonError: NSError?
    let result: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments, error:&jsonError)
    
    if let jsonError = jsonError {
        let error = JParseJsonError(nativeError: jsonError, data: data, context: context)
        return JResult.error(error)
    }
    
    return JResult.value(result)
}

//TODO AnyObject should be Printable
public func asyncJsonDataParserWithContext(data: NSData, context: AnyObject?) -> JAsyncTypes<AnyObject>.JAsync {
    
    let loadDataBlock = { () -> JResult<AnyObject> in
        
        return jsonObjectWithData(data, context)
    }
    
    return asyncWithSyncOperationAndQueue(loadDataBlock, "com.jff.json_tool_library.parse_json")
}

public func asyncJsonDataParser(data: NSData) -> JAsyncTypes<AnyObject>.JAsync {
    return asyncJsonDataParserWithContext(data, nil)
}

public func asyncBinderJsonDataParser() -> JAsyncTypes2<NSData, AnyObject>.JAsyncBinder {
    
    return { (data: NSData) -> JAsyncTypes<AnyObject>.JAsync in
        return asyncJsonDataParser(data)
    }
}
