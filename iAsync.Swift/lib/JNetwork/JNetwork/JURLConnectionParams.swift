//
//  JURLConnectionParams.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public typealias JInputStreamBuilder = () -> NSInputStream

//TODO should be struct
public class JURLConnectionParams : NSObject, Printable, NSCopying {
    
    public typealias HeadersType = [String:String]
    
    public let url       : NSURL
    public let httpBody  : NSData?
    public let httpMethod: String?
    public let headers   : HeadersType?
    
    public let totalBytesExpectedToWrite: Int64
    public let httpBodyStreamBuilder    : JInputStreamBuilder?
    public let certificateCallback      : JShouldAcceptCertificateForHost?
    
    required public init(
        url                      : NSURL,
        httpBody                 : NSData? = nil,
        httpMethod               : String? = nil,
        headers                  : HeadersType? = nil,
        totalBytesExpectedToWrite: Int64 = 0,
        httpBodyStreamBuilder    : JInputStreamBuilder? = nil,
        certificateCallback      : JShouldAcceptCertificateForHost? = nil)
    {
        self.url        = url
        self.httpBody   = httpBody
        self.httpMethod = httpMethod
        self.headers    = headers
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        self.httpBodyStreamBuilder     = httpBodyStreamBuilder
        self.certificateCallback       = certificateCallback
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(
            url                      : self.url,
            httpBody                 : self.httpBody,
            httpMethod               : self.httpMethod,
            headers                  : self.headers,
            totalBytesExpectedToWrite: self.totalBytesExpectedToWrite,
            httpBodyStreamBuilder    : self.httpBodyStreamBuilder,
            certificateCallback      : self.certificateCallback)
    }
    
    public override var description: String {
        return "<JURLConnectionParams url:\(url), httpBody:\(httpBody?.toString()), headers:\(headers)>"
    }
}
