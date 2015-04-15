//
//  JRegex.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 17.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//
//  source: http://benscheirman.com/2014/06/regex-in-swift/

import Foundation

class JRegex {
    let internalExpression: NSRegularExpression!
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, count(input)))
        return matches.count > 0
    }
}

infix operator =~ {}

func =~ (input: String, pattern: String) -> Bool {
    return JRegex(pattern).test(input)
}
