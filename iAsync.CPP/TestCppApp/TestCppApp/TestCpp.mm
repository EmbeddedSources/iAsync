
#import "TestCpp.h"

#include <algorithm>
#include <cstdlib>
#include <iostream>
#include <iterator>
#include <vector>

#import "JAsyncDefinitions.hpp"

@implementation TestCpp

+ (void)test
{
    //OnFinish<int> func_ =
    async::Async<int> func = [] (async::OnFinish<int> onFinish) -> async::Handler
    {
        onFinish(322);
        return async::StubHandlerBlock;
    };
    
    func([] (int result) -> void {
        std::cout << "line: " << result;
    });
    
//    int i;
//    auto x3a = i; // decltype(x3a) - int
//    decltype(auto) x3d = i; // decltype(x3d) - int
//    auto x4a = (i); // decltype(x4a) - int
//    decltype((i)) x4d = (i); // decltype(x4d) - int&
//    auto x5a = f(); // decltype(x5a) - int
//    decltype(f()) x5d = f(); // decltype(x5d) - int&&
}

@end
