//
//  Session.cpp
//  TestCppApp
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 Tryst. All rights reserved.
//

#include "Session.hpp"

//static  testApiFunc()
async::Async<float> Session::testApiFunc() {
    
    async::Async<float> func = [] (async::OnFinish<int> onFinish) -> async::Handler
    {
        onFinish(23.0);
        return async::StubHandlerBlock;
    };
    
    return func;
}
