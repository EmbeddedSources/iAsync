//
//  JJsonObject.swift
//  JJsonTools
//
//  Created by Vladimir Gorbenko on 18.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public func >>=<A, B, R>(obj: (JResult<A>, JResult<B>), f: (A, B) -> JResult<R>) -> JResult<R> {
    
    return obj.0 >>= { a -> JResult<R> in
        return obj.1 >>= { b -> JResult<R> in
            return f(a, b)
        }
    }
}

public func >>=<A, B, C, R>(obj: (JResult<A>, JResult<B>, JResult<C>), f: (A, B, C) -> JResult<R>) -> JResult<R> {
    
    return obj.0 >>= { a -> JResult<R> in
        return (obj.1, obj.2) >>= { (b, c) -> JResult<R> in
            return f(a, b, c)
        }
    }
}

public func >>=<A, B, C, D, R>(obj: (JResult<A>, JResult<B>, JResult<C>, JResult<D>), f: (A, B, C, D) -> JResult<R>) -> JResult<R> {
    
    return obj.0 >>= { a -> JResult<R> in
        return (obj.1, obj.2, obj.3) >>= { (b, c, d) -> JResult<R> in
            return f(a, b, c, d)
        }
    }
}

public func >>=<A, B, C, D, E, R>(obj: (JResult<A>, JResult<B>, JResult<C>, JResult<D>, JResult<E>), f: (A, B, C, D, E) -> JResult<R>) -> JResult<R> {
    
    return obj.0 >>= { a -> JResult<R> in
        return (obj.1, obj.2, obj.3, obj.4) >>= { (b, c, d, e) -> JResult<R> in
            return f(a, b, c, d, e)
        }
    }
}

public func >>=<A, B, C, D, E, F, R>(obj: (JResult<A>, JResult<B>, JResult<C>, JResult<D>, JResult<E>, JResult<F>), function: (A, B, C, D, E, F) -> JResult<R>) -> JResult<R> {
    
    return obj.0 >>= { a -> JResult<R> in
        return (obj.1, obj.2, obj.3, obj.4, obj.5) >>= { (b, c, d, e, f) -> JResult<R> in
            return function(a, b, c, d, e, f)
        }
    }
}

public func >>=<A, B, C, D, E, F, G, R>(obj: (JResult<A>, JResult<B>, JResult<C>, JResult<D>, JResult<E>, JResult<F>, JResult<G>), function: (A, B, C, D, E, F, G) -> JResult<R>) -> JResult<R> {
    
    return obj.0 >>= { a -> JResult<R> in
        return (obj.1, obj.2, obj.3, obj.4, obj.5, obj.6) >>= { (b, c, d, e, f, g) -> JResult<R> in
            return function(a, b, c, d, e, f, g)
        }
    }
}

public func >>=<A, B, C, D, E, F, G, H, R>(obj: (JResult<A>, JResult<B>, JResult<C>, JResult<D>, JResult<E>, JResult<F>, JResult<G>, JResult<H>), function: (A, B, C, D, E, F, G, H) -> JResult<R>) -> JResult<R> {
    
    return obj.0 >>= { a -> JResult<R> in
        return (obj.1, obj.2, obj.3, obj.4, obj.5, obj.6, obj.7) >>= { (b, c, d, e, f, g, h) -> JResult<R> in
            return function(a, b, c, d, e, f, g, h)
        }
    }
}

public enum JJsonValue : Printable {
    
    case JJsonArray([JJsonValue])
    case JJsonObject([String:JJsonValue])
    case JJsonNumber(Double)
    case JJsonString(String)
    case JJsonBool(Bool)
    case JJsonNull()

    //TODO AnyObject should be Printable
    public static func createWithData(data: NSData, context: AnyObject?) -> JResult<JJsonValue> {
        
        let jsonObject = jsonObjectWithData(data, context)
        
        return jsonObject >>= { jsonObject -> JResult<JJsonValue> in
            
            return self.create(jsonObject)
        }
    }
    
    public static func create(rawObject: AnyObject) -> JResult<JJsonValue> {
        return createJsonValue(rawObject, currentObject: rawObject)
    }
    
    private static func createJsonValue(rootObject: AnyObject, currentObject: AnyObject) -> JResult<JJsonValue> {
        
        switch currentObject {
        case let values as NSDictionary:
            
            let valuesMap = values as! [String:AnyObject]
            
            let result = valuesMap >>= { self.createJsonValue(rootObject, currentObject: $0.1) }
            
            return result >>= { JResult.value(JJsonObject($0)) }
        case let values as NSArray:
            
            let valuesAr = values as [AnyObject]
            let result = valuesAr >>= { self.createJsonValue(rootObject, currentObject: $0) }
            
            return result >>= { JResult.value(JJsonArray($0)) }
        case let value as NSNull:
            return JResult.value(JJsonNull())
        case let value as NSString:
            return JResult.value(JJsonString(value as! String))
        case let value as NSNumber:
            if String.fromCString(value.objCType) == "c" {
                return JResult.value(JJsonBool(value.boolValue))
            }
            return JResult.value(JJsonNumber(value.doubleValue))
        default:
            let error = JInvalidRawJsonObjectError()
            error.rootJsonObject    = rootObject
            error.invalidJsonObject = currentObject
            return JResult.error(error)
        }
    }
    
    public func dict(key: String) -> JResult<[String:JJsonValue]> {
        
        return self[key] >>= { $0.dict }
    }
    
    public var dict: JResult<[String:JJsonValue]> {
        switch self {
        case let .JJsonObject(value):
            return JResult.value(value)
        default:
            let error = JValidationTypeJsonObjectError()
            error.expectedType = "Dictionary"
            error.jsonValue    = self
            return JResult.error(error)
        }
    }
    
    public func optionString(path: JPath) -> JResult<String?> {
        
        if let value = optionValue(path) {
            return value.string >>= { JResult.value($0) }
        }
        return JResult.value(nil)
    }
    
    public func optionString(key: String) -> JResult<String?> {
        
        return optionString(JPath(pathElements: [key]))
    }
    
    public func string(path: JPath) -> JResult<String> {
        
        return self[path] >>= { $0.string }
    }
    
    public func string(key: String) -> JResult<String> {
        
        return self[key] >>= { $0.string }
    }
    
    public var string: JResult<String> {
        switch self {
        case let .JJsonString(value):
            return JResult.value(value)
        default:
            let error = JValidationTypeJsonObjectError()
            error.expectedType = "String"
            error.jsonValue    = self
            return JResult.error(error)
        }
    }
    
    public func optionNumber(path: JPath) -> JResult<Double?> {
        
        if let value = optionValue(path) {
            return value.number >>= { JResult.value($0) }
        }
        return JResult.value(nil)
    }
    
    public func optionNumber(key: String) -> JResult<Double?> {
        
        return optionNumber(JPath(pathElements: [key]))
    }
    
    public func number(path: JPath) -> JResult<Double> {
        
        return self[path] >>= { $0.number }
    }
    
    public func number(key: String) -> JResult<Double> {
        
        return self[key] >>= { $0.number }
    }
    
    public var number: JResult<Double> {
        switch self {
        case let .JJsonNumber(value):
            return JResult.value(value)
        default:
            let error = JValidationTypeJsonObjectError()
            error.expectedType = "Double"
            error.jsonValue    = self
            return JResult.error(error)
        }
    }
    
    public func optionBool(key: String) -> JResult<Bool?> {
        
        if let value = optionValue(key) {
            return value.bool >>= { JResult.value($0) }
        }
        return JResult.value(nil)
    }
    
    public func bool(key: String) -> JResult<Bool> {
        
        return self[key] >>= { $0.bool }
    }
    
    var bool: JResult<Bool> {
        switch self {
        case let .JJsonBool(value):
            return JResult.value(value)
        default:
            let error = JValidationTypeJsonObjectError()
            error.expectedType = "Double"
            error.jsonValue    = self
            return JResult.error(error)
        }
    }
    
    public func array(path: JPath) -> JResult<[JJsonValue]> {
        
        return self[path] >>= { $0.array }
    }
    
    public func array(key: String) -> JResult<[JJsonValue]> {
        
        return self.array(JPath(pathElements: [key]))
    }
    
    public var array: JResult<[JJsonValue]> {
        switch self {
        case let .JJsonArray(value):
            return JResult.value(value)
        default:
            let error = JValidationTypeJsonObjectError()
            error.expectedType = "Array"
            error.jsonValue    = self
            return JResult.error(error)
        }
    }
    
    public func optionValue(path: JPath) -> JJsonValue? {
        
        switch self[path] {
        case let .Value(v):
            switch v.value {
            case let .JJsonNull():
                return nil
            default:
                return v.value
            }
        default:
            return nil
        }
    }
    
    public func optionValue(key: String) -> JJsonValue? {
        
        return optionValue(JPath(pathElements: [key]))
    }
    
    public subscript(path: JPath) -> JResult<JJsonValue> {
        
        assert(!path.isEmpty)
        
        let leftComponents = path.leftComponents
        let subElement     = self[path.firstComponent]
        
        if leftComponents.isEmpty {
            return subElement
        }
        
        let result = subElement >>= { $0[leftComponents] }
        
        switch result {
        case let .Value(v):
            return result
        case let .Error(error):
            
            if let error = error as? JNoDataForKeyInJsonObjectError {
                
                let noDataForKeyError = JNoDataForPathInJsonObjectError()
                
                noDataForKeyError.jsonValue = error.jsonValue
                noDataForKeyError.key       = error.key
                noDataForKeyError.path      = path
                
                return JResult.error(noDataForKeyError)
            }
            return result
        }
    }
    
    public subscript(key: String) -> JResult<JJsonValue> {
        
        let noDataForKeyError = { () -> JResult<JJsonValue> in
            
            let error = JNoDataForKeyInJsonObjectError()
            error.key       = key
            error.jsonValue = self
            return JResult.error(error)
        }
            
        switch self {
        case let .JJsonObject(dict):
            if let result = dict[key] {
                return JResult.value(result)
            }
            return noDataForKeyError()
        default:
            return noDataForKeyError()
        }
    }
    
    public var description: String {
        switch self {
        case let .JJsonNull()   : return "JJsonNull()"
        case let .JJsonBool(b)  : return "JJsonBool(\(b))"
        case let .JJsonString(s): return "JJsonString(\(s))"
        case let .JJsonNumber(n): return "JJsonNumber(\(n))"
        case let .JJsonObject(o): return "JJsonObject(\(o))"
        case let .JJsonArray(a) : return "JJsonArray(\(a))"
        }
    }
    
    //TODO pretty print - https://github.com/dankogai/swift-json/blob/master/json.swift
}
