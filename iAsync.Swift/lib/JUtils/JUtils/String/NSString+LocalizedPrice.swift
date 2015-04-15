//
//  NSString+LocalizedPrice.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 09.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSString {
    
    class func localizedPrice(price: NSNumber, priceLocale: NSLocale) -> NSString {
        
        let numberFormatter = NSNumberFormatter()
        
        numberFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        numberFormatter.numberStyle       = NSNumberFormatterStyle.CurrencyStyle
        numberFormatter.locale            = priceLocale
        
        let result = numberFormatter.stringFromNumber(price)
        return result!
    }
}
