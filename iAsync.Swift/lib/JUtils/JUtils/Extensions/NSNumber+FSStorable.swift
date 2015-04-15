//
//  NSNumber+FSStorable.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

private func parseNumber<T>(documentFile: String, scanner: (String) -> T?) -> T? {
    
    let path = NSString.documentsPathByAppendingPathComponent(documentFile)
    
    let string = NSString(
        contentsOfFile :path,
        encoding       :NSUTF8StringEncoding,
        error          :nil) as? String
    
    if let value = string {
        return scanner(value)
    }
    
    return nil
}

public func writeToFile<T>(object: T, documentFile: String) -> Bool {
    
    let string = toString(object)
    
    //TODO should be String, not NSString type
    let fileName :NSString = NSString.documentsPathByAppendingPathComponent(documentFile)
    
    let result = string.writeToFile(
        fileName as String,
        atomically: true,
        encoding  : NSUTF8StringEncoding,
        error     : nil)
    
    if result {
        fileName.addSkipBackupAttribute()
    }
    
    return result
}

public extension Int {
    
    public static func readFromFile(documentFile: String) -> Int? {
        
        let scanner = { (string: String) -> Int? in
            var scannedNumber: Int = 0
            let scanner = NSScanner(string: string)
            if scanner.scanInteger(&scannedNumber) {
                return scannedNumber
            }
            return nil
        }
        
        return parseNumber(documentFile, scanner)
    }
}

public extension Double {
    
    public static func readFromFile(documentFile: String) -> Double? {
        
        let scanner = { (string: String) -> Double? in
            var scannedNumber: Double = 0
            let scanner = NSScanner(string: string)
            if scanner.scanDouble(&scannedNumber) {
                return scannedNumber
            }
            return nil
        }
        
        return parseNumber(documentFile, scanner)
    }
}

public extension Bool {
    
    public static func readFromFile(documentFile: String) -> Bool? {
        
        if let result = Int.readFromFile(documentFile) {
            return result != 0
        }
        
        return nil
    }
}
