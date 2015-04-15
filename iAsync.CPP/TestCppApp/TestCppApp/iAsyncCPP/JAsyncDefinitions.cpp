//
//  JAsyncBlockDefinitions.cpp
//  TestCppApp
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 Tryst. All rights reserved.
//

#include <stdio.h>

#include "JAsyncDefinitions.hpp"

namespace async {
    
    Handler StubHandlerBlock = [](HandlerTask task) -> void {};
}
