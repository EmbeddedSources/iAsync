//
//  NSString+FileAttributes.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//import "sys/xattr.h"

public extension NSString {
    
    func addSkipBackupAttribute() {
        
        var b: UInt8 = 1
        let attributeName = "com.apple.MobileBackup".UTF8String
        
        let result = withUnsafePointer(&b) { value -> Int32 in
            let result = bridg_setxattr(self.fileSystemRepresentation, attributeName, value, Int(1), UInt32(0), CInt(0))
            return result
        }
        
        if result != -1 {
            return
        }
        
        let logger = { (log: String) in
            jLogger.logError(log)
        }
        
        switch (errno)
        {
        case ENOENT:
            //options is set to XATTR_REPLACE and the named attribute does not exist.
            logger("addSkipBackupAttribute: No such file or directory")
        case EEXIST, ENOATTR:
            //options is set to XATTR_REPLACE and the named attribute does not exist.
            let log = "addSkipBackupAttribute: \(attributeName) attribute does not exist"
            logger(log)
        case ENOTSUP:
            logger("addSkipBackupAttribute: The file system does not support extended attributes or has them disabled.")
        case EROFS:
            logger("addSkipBackupAttribute: The file system is mounted read-only.")
        case ERANGE:
            logger("addSkipBackupAttribute: The data size of the attribute is out of range (some attributes have size restric-tions).")
        case EPERM:
            logger("addSkipBackupAttribute: Attributes cannot be associated with this type of object. For example, attributes are not allowed for resource forks.")
        case EINVAL:
            logger("addSkipBackupAttribute: name or options is invalid. name must be valid UTF-8 and options must make sense.")
        case ENOTDIR:
            logger("addSkipBackupAttribute: A component of path is not a directory.")
        case ENAMETOOLONG:
            logger("addSkipBackupAttribute: name exceeded XATTR_MAXNAMELEN UTF-8 bytes, or a component of path exceeded NAME_MAX characters, or the entire path exceeded PATH_MAX characters.")
        case EACCES:
            logger("addSkipBackupAttribute: Search permission is denied for a component of path or permission to set the attribute is denied.")
        case ELOOP:
            logger("addSkipBackupAttribute: Too many symbolic links were encountered resolving path.")
        case EIO:
            logger("addSkipBackupAttribute: An I/O error occurred while reading from or writing to the file system.")
        case E2BIG:
            logger("addSkipBackupAttribute: The data size of the extended attribute is too large.")
        case ENOSPC:
            logger("addSkipBackupAttribute: Not enough space left on the file system.")
        default:
            logger("addSkipBackupAttribute: unknown error type")
        }
    }
}
