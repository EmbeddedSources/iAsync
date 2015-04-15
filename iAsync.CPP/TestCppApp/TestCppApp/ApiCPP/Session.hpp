//
//  Session.h
//  TestCppApp
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 Tryst. All rights reserved.
//

#ifndef __TestCppApp__Session__
#define __TestCppApp__Session__

#include <stdio.h>

#include "JAsyncDefinitions.hpp"

class Session {
    
public:
    static async::Async<float> testApiFunc();
};

#endif /* defined(__TestCppApp__Session__) */
