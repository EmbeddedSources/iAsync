//
//  JSocialFacebookUser.swift
//  JSocial
//
//  Created by Vladimir Gorbenko on 07.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//Image urls docs
// http://developers.facebook.com/docs/reference/api/using-pictures/

public class JSocialFacebookUser : NSObject {
    
    public let facebookID: String
    let email            : String?
    public let name      : String?
    public let gender    : String?
    public let birthday  : NSDate?
    public let biography : String?
    public let photoURL  : NSURL?
    
    @objc public required init(
        facebookID: String,
        email     : String?,
        name      : String?,
        gender    : String?,
        birthday  : NSDate?,
        biography : String?,
        photoURL  : NSURL?)
    {
        self.facebookID = facebookID
        self.email      = email
        self.name       = name
        self.gender     = gender
        self.birthday   = birthday
        self.biography  = biography
        self.photoURL   = photoURL
    }
}

extension JSocialFacebookUser : Equatable {}

public func ==(lhs: JSocialFacebookUser, rhs: JSocialFacebookUser) -> Bool {
    
    let result = lhs.facebookID == rhs.facebookID
              && lhs.email      == rhs.email
              && lhs.name       == rhs.name
              && lhs.gender     == rhs.gender
              && lhs.birthday   == rhs.birthday
              && lhs.biography  == rhs.biography
              && lhs.photoURL   == rhs.photoURL
    return result
}
