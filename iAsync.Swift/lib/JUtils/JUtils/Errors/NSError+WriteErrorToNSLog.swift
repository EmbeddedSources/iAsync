//
//  NSError+WriteErrorToNSLog.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

private struct JErrorWithAction {
    
    let error : NSError
    let action: JSimpleBlock
}

private var nsLogErrorsQueue  : [JErrorWithAction] = []
private var jLoggerErrorsQueue: [JErrorWithAction] = []

private func delayedPerformAction(error: NSError, action: JSimpleBlock, inout queue: [JErrorWithAction])
{
    if firstMatch(queue, { $0.error === error }) != nil {
        return
    }
    
    queue.append(JErrorWithAction(error: error, action: action))
    
    if queue.count == 1 {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let tmpQueue = queue
            queue.removeAll(keepCapacity: true)
            for info in tmpQueue {
                info.action()
            }
        })
    }
}

public extension NSError {
    
    //TODO make it protected
    var errorLogDescription: String? {
        return "\(self.dynamicType) : \(localizedDescription), domain : \(domain) code : \(code.description)"
    }
    
    func writeErrorToNSLog() {
        
        let action = { () -> () in
            if let logStr = self.errorLogDescription {
                NSLog("only log - %@", logStr)
            }
        }
        
        delayedPerformAction(self, action, &nsLogErrorsQueue)
    }
    
    func writeErrorWithJLogger() {
        
        let action = { () -> () in
            if let logStr = self.errorLogDescription {
                jLogger.logError(logStr)
            }
        }
        
        delayedPerformAction(self, action, &jLoggerErrorsQueue)
    }
}
