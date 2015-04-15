//
//  String+toDouble.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 20.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}