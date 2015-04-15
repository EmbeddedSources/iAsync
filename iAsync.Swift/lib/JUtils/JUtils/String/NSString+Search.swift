//
//  NSString+Search.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSString {
    
    private func numberofOccurencesWithRangeSearcher(
        @noescape rangeSearcher: (NSRange) -> NSRange, step: Int) -> Int {
        
        var result = 0
        
        var searchRange = NSMakeRange(0, length)
        var range = rangeSearcher(searchRange)
        
        while range.location != Foundation.NSNotFound {
            
            ++result
            
            searchRange.location = range.location + step
            searchRange.length   = length - searchRange.location
            if searchRange.location >= length {
                break
            }
            
            range = rangeSearcher(searchRange)
        }
        
        return result
    }
    
    func numberOfCharacterFromString(string: String) -> Int {
        
        let set = NSCharacterSet(charactersInString: string)
        
        let rangeSearcher = { (rangeToSearch: NSRange) -> NSRange in
            return self.rangeOfCharacterFromSet(set, options: .LiteralSearch, range: rangeToSearch)
        }
        
        return numberofOccurencesWithRangeSearcher(rangeSearcher, step: 1)
    }
    
    func numberOfStringsFromString(string: String) -> Int {
        
        let rangeSearcher = { (rangeToSearch: NSRange) -> NSRange in
            return self.rangeOfString(string, options: .LiteralSearch, range: rangeToSearch)
        }
        
        let nsStringLength = (string as NSString).length
        
        return numberofOccurencesWithRangeSearcher(rangeSearcher, step: nsStringLength)
    }
    
    func caseInsensitiveContainsString(string: String) -> Bool {
        
        let range = self.rangeOfString(string, options: .CaseInsensitiveSearch, range: NSMakeRange(0, length))
        return range.location != Foundation.NSNotFound
    }
}
