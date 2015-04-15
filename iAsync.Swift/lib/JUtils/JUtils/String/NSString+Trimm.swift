//
//  NSString+Trimm.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 08.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSString {
    
    private func rangeForQuotesRemoval() -> NSRange {
        
        let quotedString = self
        
        let firstQuoteOffset = 1
        let quotesCount      = 2
        let rangeLength = quotedString.length - quotesCount
        
        let result = NSMakeRange(firstQuoteOffset, rangeLength)
        return result
    }
    
    func stringByTrimmingWhitespaces() -> String {
        
        let set = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        return stringByTrimmingCharactersInSet(set)
    }
    
    func stringByTrimmingPunctuation() -> String  {
        
        let set = NSCharacterSet.punctuationCharacterSet()
        return stringByTrimmingCharactersInSet(set)
    }
    
    func stringByTrimmingQuotes() -> NSString {
        
        let rangeWithoutQuotes = rangeForQuotesRemoval()
        let result = substringWithRange(rangeWithoutQuotes)
        
        let termWhitespaces = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        
        return result.stringByTrimmingCharactersInSet(termWhitespaces)
    }
}
