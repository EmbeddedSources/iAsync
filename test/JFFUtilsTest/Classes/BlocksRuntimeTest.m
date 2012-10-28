
#include <objc/runtime.h>

// https://github.com/ebf/CTObjectiveCRuntimeAdditions#getting-runtime-information-about-blocks

@interface TestRuntimeClass : NSObject
@end

@implementation TestRuntimeClass

@end

@interface BlocksRuntimeTest : GHTestCase
@end

//extern char *block_copyIMPTypeEncoding_np(id block);

@implementation BlocksRuntimeTest

- (void)testHookMethodWithBlock
{
}

@end
