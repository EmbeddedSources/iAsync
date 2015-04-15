//
//  JPath.swift
//  JJsonTools
//
//  Created by Vladimir Gorbenko on 19.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

infix operator </> {
associativity left
}

public func </>(path1: String, path2: String) -> JPath {
    
    return JPath(path1: path1, path2: path2)
}

public func </>(path1: JPath, path2: String) -> JPath {
    
    return JPath(path1: path1, path2: path2)
}

public func </>(path1: String, path2: JPath) -> JPath {
    
    return JPath(path1: path1, path2: path2)
}

func </>(path1: JPath, path2: JPath) -> JPath {
    
    return JPath(path1: path1, path2: path2)
}

//TODO StringLiteralConvertible
public class JPath : Printable {
    
    var pathElements = [String]()
    
    var isEmpty: Bool {
        return pathElements.isEmpty
    }
    
    var firstComponent: String {
        assert(!isEmpty)
        return pathElements[0]
    }
    
    var leftComponents: JPath {
        assert(!isEmpty)
        let subArray = Array(pathElements[1..<pathElements.count])
        return JPath(pathElements: subArray)
    }
    
    init(pathElements: [String]) {
        
        self.pathElements = pathElements
    }
    
    convenience init(path1: String, path2: String) {
        
        self.init(pathElements: [path1, path2])
    }
    
    convenience init(path1: JPath, path2: String) {
        
        self.init(path1: path1, path2: JPath(pathElements: [path2]))
    }
    
    convenience init(path1: String, path2: JPath) {
        
        self.init(path1: JPath(pathElements: [path1]), path2: path2)
    }
    
    convenience init(path1: JPath, path2: JPath) {
        
        self.init(pathElements: path1.pathElements)
        
        for element in path2.pathElements {
            
            self.pathElements.append(element)
        }
    }
    
    public var description: String {
        return "JPath< \(pathElements) >"
    }
}
