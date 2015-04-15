//
//  JAsyncDefinitions.hpp
//  TestCppApp
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 Tryst. All rights reserved.
//

#ifndef TestCppApp_JAsyncBlockDefinitions_hpp
#define TestCppApp_JAsyncBlockDefinitions_hpp

#include <functional>

namespace async {

    template <typename T>
    using OnFinish = std::function<void (const T&)>;
    
    enum class HandlerTask {
        
        HandlerTaskUnSubscribe = 0,
        HandlerTaskCancel      = 1,
        HandlerTaskResume      = 2,
        HandlerTaskSuspend     = 3,
        HandlerTaskUndefined   = 4
    };
    
    using Handler = std::function<void (const HandlerTask)>;
    
    template <typename T>
    using Async = std::function<Handler (const OnFinish<T>&)>;
    
    extern Handler StubHandlerBlock;
}

#endif
