//
//  JLogger.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 05.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public typealias JLogHandler = (level: String, log: String, context: AnyObject?) -> Void

private var staticLogHandler: JLogHandler? = nil

public let jLogger = JLogger()

public class JLogger : NSObject {
    
    private override init() {}
    
    //for objc only, todo remove
    @objc public class func sharedJLogger() -> JLogger {
        return jLogger
    }
    
    public var logHandler: JLogHandler {
        get {
            if let result = staticLogHandler {
                return result
            }
            let result = { (level: String, log: String, context: AnyObject?) in
                println("\(log): \(level)")
            }
            staticLogHandler = result
            return result
        }
        set(newLogHandler) {
            staticLogHandler = newLogHandler
        }
    }
    
    public func logError(log: String) {
        logHandler(level: "error", log: log, context: nil)
    }
    
    public func logError(context: AnyObject, log: String) {
        logHandler(level: "error", log: log, context: context)
    }
    
    func logInfo(log: String) {
        logHandler(level: "info", log: log, context: nil)
    }
    
    func log(level: String, context: AnyObject, log: String) {
        logHandler(level: level, log: log, context: context)
    }
}
