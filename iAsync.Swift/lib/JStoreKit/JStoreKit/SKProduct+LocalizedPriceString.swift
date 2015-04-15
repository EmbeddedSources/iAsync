//
//  SKProduct+LocalizedPriceString.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import StoreKit
import JUtils

public extension SKProduct {

    func localizedPriceString() -> String {
        return NSString.localizedPrice(self.price, priceLocale: self.priceLocale) as String
    }
}
