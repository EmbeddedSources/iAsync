//
//  CppToObjc.h
//  TestCppApp
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 Tryst. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JAsyncOperationsDefinitions.h"

@interface CppToObjc : NSObject

+ (JFFAsyncOperation)cppTestLoader;

@end
