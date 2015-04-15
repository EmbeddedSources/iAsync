//
//  TmpHeader.m
//  JUtils
//
//  Created by Vlafimir Gorbenko on 16.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sys/xattr.h>

int bridg_setxattr(const char *path, const char *name, const void *value, size_t size, u_int32_t position, int options) {
    
    return setxattr(path, name, value, size, position, options);
}