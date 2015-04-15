//
//  JTimer.swift
//  JTimer
//
//  Created by Vladimir Gorbenko on 26.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public typealias JCancelScheduledBlock = () -> Void
public typealias JScheduledBlock = (cancel: JCancelScheduledBlock) -> Void

//TODO remove NSObject inheritence
public class JTimer : NSObject {
    
    private var cancelBlocks = [JSimpleBlockHolder]()
    
    deinit {
        cancelAllScheduledOperations()
    }
    
    public func cancelAllScheduledOperations() {
        let cancelBlocks = self.cancelBlocks
        self.cancelBlocks.removeAll(keepCapacity: true)
        for cancelHolder in cancelBlocks {
            cancelHolder.onceSimpleBlock()()
        }
    }
    
    public class func sharedByThreadTimer() -> JTimer {
        
        let thread = NSThread.currentThread()
        
        let key = "JTimer.threadLocalTimer"
        var result: JTimer? = thread.threadDictionary[key] as? JTimer
        if result == nil {
            result = JTimer()
            thread.threadDictionary[key] = result
        }
        
        return result!
    }
    
    func addBlock(actionBlock: JScheduledBlock,
        duration     : NSTimeInterval,
        dispatchQueue: dispatch_queue_t) -> JCancelScheduledBlock
    {
        return self.addBlock(actionBlock,
            duration     : duration,
            leeway       : duration/10.0,
            dispatchQueue: dispatchQueue)
    }
    
    public func addBlock(actionBlock: JScheduledBlock,
        duration     : NSTimeInterval,
        leeway       : NSTimeInterval,
        dispatchQueue: dispatch_queue_t) -> JCancelScheduledBlock
    {
        var timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatchQueue)
        
        let delta = Int64(duration * Double(NSEC_PER_SEC))
        dispatch_source_set_timer(timer,
            dispatch_time(DISPATCH_TIME_NOW, delta),
            UInt64(delta),
            UInt64(leeway * Double(NSEC_PER_SEC)))
        
        let cancelTimerBlockHolder = JSimpleBlockHolder()
        weak var weakCancelTimerBlockHolder = cancelTimerBlockHolder
        
        cancelTimerBlockHolder.simpleBlock = { [weak self] () -> () in
            
            if timer == nil {
                return
            }
            
            dispatch_source_cancel(timer)
            timer = nil
            
            if let self_ = self {
                for (index, cancelHolder) in enumerate(self_.cancelBlocks) {
                    
                    if cancelHolder === weakCancelTimerBlockHolder! {
                        self_.cancelBlocks.removeAtIndex(index)
                        break
                    }
                }
            }
        }
        
        cancelBlocks.append(cancelTimerBlockHolder)
        
        let eventHandlerBlock = { () -> () in
            actionBlock(cancel: cancelTimerBlockHolder.onceSimpleBlock())
        }
        
        dispatch_source_set_event_handler(timer, eventHandlerBlock)
        
        dispatch_resume(timer)
        
        return cancelTimerBlockHolder.onceSimpleBlock()
    }
    
    public func addBlock(actionBlock: JScheduledBlock,
        duration: NSTimeInterval) -> JCancelScheduledBlock
    {
        return addBlock(actionBlock,
            duration: duration,
            leeway  : duration/10.0)
    }
    
    public func addBlock(actionBlock: JScheduledBlock,
        duration: NSTimeInterval,
        leeway  : NSTimeInterval) -> JCancelScheduledBlock
    {
        return addBlock(actionBlock,
            duration     : duration,
            leeway       : leeway,
            dispatchQueue: dispatch_get_main_queue())
    }
}
