//
//  JMutableAssignArray.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 19.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//compares elements by pointers only
public class JMutableAssignArray<T: NSObjectProtocol> : SequenceType, Printable {
    
    typealias Generator = Array<T>.Generator
    
    public func generate() -> Generator {
        
        let array = self.map({$0})
        return array.generate()
    }

    public init() {}
    
    private var mutableArray: [JAutoRemoveAssignProxy<T>] = []
    
    public var onRemoveObject: JSimpleBlock?
    
    public func append(object: T) {

        let proxy = JAutoRemoveAssignProxy(target: object)
        mutableArray.append(proxy)
        proxy.onAddToMutableAssignArray(self)
    }
    
    public func containsObject(object: T) -> Bool {
        
        let predicate = { (proxy: JAutoRemoveAssignProxy<T>) -> Bool in
            
            let holdedObject = proxy.target.takeUnretainedValue()
            let result = holdedObject === object
            return result
        }
        
        return any(mutableArray, predicate)
    }
    
    private func indexOfObject(object: Unmanaged<T>) -> Int {
        
        let result = { () -> Int in
            
            let ptr = object.takeUnretainedValue()
            
            for (index, proxy) in enumerate(self.mutableArray) {
                if proxy.target.takeUnretainedValue() === ptr {
                    return index
                }
            }
            return Int.max
        }()
        
        return result
    }
    
    private func removeAllObjects(object: Unmanaged<T>) {
        
        var index = indexOfObject(object)
        
        while index != Int.max {
            removeAtIndex(index)
            index = indexOfObject(object)
        }
    }
    
    public func removeObject(object: T) {
        
        let index = indexOfObject(object)
        
        if index != Int.max {
            removeAtIndex(index)
        }
    }
    
    public func removeAtIndex(index: Int) {
        
        let proxy = mutableArray[index]
        proxy.onRemoveFromMutableAssignArray(self)
        mutableArray.removeAtIndex(index)
        
        onRemoveObject?()
    }
    
    public func removeAll(keepCapacity: Bool) {
        
        for proxy in mutableArray {
            proxy.onRemoveFromMutableAssignArray(self)
        }
        
        mutableArray.removeAll(keepCapacity: keepCapacity)
    }
    
    public subscript(index: Int) -> T {
        
        let proxy = mutableArray[index] as JAutoRemoveAssignProxy
        return proxy.target.takeUnretainedValue()
    }
    
    public func indexOfObject(object: T) -> Int {
        
        let ptr = Unmanaged<T>.passUnretained(object as T)
        let index = indexOfObject(ptr)
        
        return index
    }
    
    public var count: Int {
        return mutableArray.count
    }
    
    public func map<U>(transform: (T) -> U) -> [U] {
    
        return mutableArray.map({transform($0.target.takeUnretainedValue())})
    }

    public var last: T? {
        if let proxy = mutableArray.last {
            return proxy.target.takeUnretainedValue()
        }
        return nil
    }
    
    public var description: String {
        return mutableArray.map({$0.target.takeUnretainedValue()}).description
    }
    
    deinit {
        removeAll(false)
    }
}

private class JAutoRemoveAssignProxy<T: NSObjectProtocol> : JAssignObjectHolder<T> {
    
    weak var blockHolder: JOnDeallocBlockOwner?
    
    init(target: T) {
        
        let ptr = Unmanaged<T>.passUnretained(target)
        super.init(targetPtr: ptr)
    }
    
    func onAddToMutableAssignArray(array: JMutableAssignArray<T>) {
        
        let unretainedArray = Unmanaged<JMutableAssignArray<T>>.passUnretained(array)
        let unretainedSelf  = Unmanaged<JAutoRemoveAssignProxy>.passUnretained(self)
        let onDeallocBlock = { () -> () in
            unretainedArray.takeUnretainedValue().removeAllObjects(unretainedSelf.takeUnretainedValue().target)
        }
        let blockHolder = JOnDeallocBlockOwner(block:onDeallocBlock)
        self.blockHolder = blockHolder
        (target.takeUnretainedValue() as! NSObject).addOnDeallocBlockHolder(blockHolder)
    }
    
    func onRemoveFromMutableAssignArray(array: JMutableAssignArray<T>) {
        
        if let blockHolder = self.blockHolder {
            blockHolder.block = nil
            self.blockHolder  = nil
            //TODO self.target test count of ownerships here
            (self.target.takeUnretainedValue() as! NSObject).removeOnDeallocBlockHolder(blockHolder)
        }
    }
}
