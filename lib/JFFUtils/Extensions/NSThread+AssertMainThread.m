#import "NSThread+AssertMainThread.h"

@implementation NSThread (AssertMainThread)

+(void)assertMainThread
{
   NSAssert( [ NSThread isMainThread ], @"should be called only from main thread only" );
}

@end
