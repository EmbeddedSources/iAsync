//
//  CppToObjc.m
//  TestCppApp
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 Tryst. All rights reserved.
//

#import "CppToObjc.h"

#import "Session.hpp"

template<typename Res>
static id resultConverter(Res result)
{
    assert(false);
    return nil;
}

template<>
id resultConverter(float result)
{
    return @(result);
}

template<typename Res>
static JFFAsyncOperation toObjcLoader(async::Async<Res> loader)
{
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        auto handler = loader([doneCallback] (const Res &result) -> void {
            
            id objcResult = resultConverter<Res>(result);
            doneCallback(objcResult, nil);
        });
        
        return ^(JAsyncHandlerTask task) {
            handler(async::HandlerTask(task));
        };
    };
}

@implementation CppToObjc

+ (JFFAsyncOperation)cppTestLoader
{
    return toObjcLoader(Session::testApiFunc());
}

@end
