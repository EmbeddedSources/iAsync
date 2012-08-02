//can not be under arc
#import "NSObject+InstancesCount.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>
#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/JFFClangLiterals.h>

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

//source: http://developer.apple.com/library/mac/#qa/qa1361/_index.html
static bool AmIBeingDebugged(void)
// Returns true if the current process is being debugged (either 
// running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;

    // Initialize the flags so that, if sysctl fails for some bizarre 
    // reason, we get a predictable result.

    info.kp_proc.p_flag = 0;

    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.

    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();

    // Call sysctl.

    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);

    // We're being debugged if the P_TRACED flag is set.

    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

@interface JFFNSObjectInstancesCounter : NSObject

@property ( nonatomic, retain ) NSMutableDictionary* instancesNumberByClassName;

@end

@implementation JFFNSObjectInstancesCounter

-(void)dealloc
{
    [ self->_instancesNumberByClassName release ];

    [ super dealloc ];
}

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        self->_instancesNumberByClassName = [ NSMutableDictionary new ];
    }

    return self;
}

+(id)sharedObjectInstancesCounter
{
    static dispatch_once_t once_;
    static id instance_;
    dispatch_once( &once_, ^{ instance_ = [ [ self class ] new ]; } );
    return instance_;
}

-(void)incrementInstancesCountForClass:( Class )class_
{
    @synchronized( self )
    {
        NSString* className_ = NSStringFromClass( class_ );
        NSNumber* number_ = self.instancesNumberByClassName[ className_ ];
        NSUInteger instances_count_  = [ number_ unsignedIntValue ];
        NSNumber* instancesCountNum_ = @( ++instances_count_ );
        self.instancesNumberByClassName[ instancesCountNum_ ] = className_;
    }
}

-(void)decrementInstancesCountForClass:( Class )class_
{
    @synchronized( self )
    {
        NSString* className_ = NSStringFromClass( class_ );
        NSNumber* number_ = self.instancesNumberByClassName[ className_ ];
        NSUInteger instancesCount_  = [ number_ unsignedIntValue ];
        NSNumber* instancesCountNum_ = @( --instancesCount_ );
        self.instancesNumberByClassName[ instancesCountNum_ ] = className_;
    }
}

+(void)incrementInstancesCountForClass:( Class )class_
{
    [ [ JFFNSObjectInstancesCounter sharedObjectInstancesCounter ] incrementInstancesCountForClass: class_ ];
}

+(void)decrementInstancesCountForClass:( Class )class_
{
    [ [ JFFNSObjectInstancesCounter sharedObjectInstancesCounter ] decrementInstancesCountForClass: class_ ];
}

+(id)instancesCounterAllocatorForClass:( Class )class_
                         nativeAllocor:( id (^)( void ) )native_
{
    [ JFFNSObjectInstancesCounter incrementInstancesCountForClass: class_ ];
    NSObject* result_ = native_();
    [ result_ addOnDeallocBlock: ^void( void )
     {
         [ JFFNSObjectInstancesCounter decrementInstancesCountForClass: class_ ];
     } ];
    return (id)result_;
}

+(id)allocWithZoneHook:( NSZone* )zone_
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

+(id)alloCWithZonePrototype:( NSZone* )zone_
{
    return [ JFFNSObjectInstancesCounter instancesCounterAllocatorForClass: [ self class ]
                                                             nativeAllocor: ^id( void )
            {
                return [ self allocWithZoneHook: zone_ ];
            } ];
}

+(id)alloCWithZoneToAdding:( NSZone* )zone_
{
    return [ JFFNSObjectInstancesCounter instancesCounterAllocatorForClass: [ self class ]
                                                             nativeAllocor: ^id( void )
    {
        return [ super allocWithZone: zone_ ];
    } ];
}

-(void)enableInstancesCountingForClass:( Class )class_
{
    @synchronized( self )
    {
        NSString* className_ = NSStringFromClass( class_ );
        NSNumber* number_ = self.instancesNumberByClassName[ className_ ];
        if ( !number_ )
        {
            self.instancesNumberByClassName[ @0 ] = className_;
            
            {
                BOOL method_added_ = [ [ self class ] addClassMethodIfNeedWithSelector: @selector( alloCWithZoneToAdding: )
                                                                               toClass: class_
                                                                     newMethodSelector: @selector( allocWithZone: ) ];

                if ( !method_added_ )
                {
                    // create name allocWithZoneHook dynamicaly and allocWithZonePrototype use block instead
                    [ [ self class ] hookClassMethodForClass: class_
                                                withSelector: @selector( allocWithZone: )
                                     prototypeMethodSelector: @selector( alloCWithZonePrototype: )
                                          hookMethodSelector: @selector( allocWithZoneHook: ) ];
                }
            }
        }
    }
}

-(NSUInteger)instancesCountForClass:( Class )class_
{
    @synchronized( self )
    {
        NSString* class_name_ = NSStringFromClass( class_ );
        NSNumber* number_ = self.instancesNumberByClassName[ class_name_ ];
        return [ number_ unsignedIntValue ];
    }
}

@end

@implementation NSObject (InstancesCount)

+(void)enableInstancesCounting
{
    // try to fix for release mode also
    if ( AmIBeingDebugged() )
        [ [ JFFNSObjectInstancesCounter sharedObjectInstancesCounter ] enableInstancesCountingForClass: [ self class ] ];
}

+(NSUInteger)instancesCount
{
    return [ [ JFFNSObjectInstancesCounter sharedObjectInstancesCounter ] instancesCountForClass: [ self class ] ];
}

@end
