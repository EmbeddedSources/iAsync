#import <Foundation/Foundation.h>

#if defined( __IPHONE_5_0 ) && ( __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0 )
    #define AUTORELEASE_POOL_BEGIN @autoreleasepool
    #define AUTORELEASE_POOL_END
#else
    #define AUTORELEASE_POOL_BEGIN NSAutoreleasePool* local_pool_ = [ [ NSAutoreleasePool alloc ] init ];
       
    #define AUTORELEASE_POOL_END [ local_pool_ drain ];
    
    #define __bridge_transfer
#endif

#ifndef cfretain
   #define cfretain assign
#endif

