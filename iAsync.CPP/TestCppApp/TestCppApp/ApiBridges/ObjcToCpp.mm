//
//  ObjcToCpp.m
//  TestCppApp
//
//  Created by Vladimir Gorbenko on 20.03.15.
//  Copyright (c) 2015 Tryst. All rights reserved.
//

#import "ObjcToCpp.hpp"

#import "JAsyncOperationsDefinitions.h"

template <typename Res>
using Converter = std::function<Res (id)>;

template<typename Res>
static async::Async<Res> toCppLoader(JFFAsyncOperation loader, Converter<Res> converter)
{
    return [loader, converter] (async::OnFinish<int> onFinish) -> async::Handler
    {
        JFFAsyncOperationHandler handler = loader(nil, nil, ^(id result, NSError *error) {
            
            onFinish(converter(result));
        });
        
        return [handler](async::HandlerTask task) -> void {
            
            handler(JAsyncHandlerTask(task));
        };
    };
}

static Converter<int> numberToInt()
{
    return [] (id result) -> int {
        NSNumber *numResult = result;
        return numResult.intValue;
    };
}

async::Async<int> testObjcLoader()
{
    JFFAsyncOperation loader = ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                                         JFFAsyncOperationChangeStateCallback stateCallback,
                                                         JFFDidFinishAsyncOperationCallback doneCallback) {
        
        if (doneCallback) {
            doneCallback(@56, nil);
        }
        
        return JFFStubHandlerAsyncOperationBlock;
    };
    
    return toCppLoader<int>(loader, numberToInt());
}
