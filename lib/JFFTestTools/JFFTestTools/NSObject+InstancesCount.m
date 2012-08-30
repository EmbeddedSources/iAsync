//can not be under arc
#import "NSObject+InstancesCount.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>
#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/JFFClangLiterals.h>

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
        NSNumber* number_ = self->_instancesNumberByClassName[ className_ ];
        NSUInteger instancesCount_  = [ number_ unsignedIntValue ];
        NSNumber* instancesCountNum_ = @( ++instancesCount_ );
        self->_instancesNumberByClassName[ className_ ] = instancesCountNum_;
    }
}

-(void)decrementInstancesCountForClass:( Class )class_
{
    @synchronized( self )
    {
        NSString* className_ = NSStringFromClass( class_ );
        NSNumber* number_ = self->_instancesNumberByClassName[ className_ ];
        NSUInteger instancesCount_  = [ number_ unsignedIntValue ];
        NSNumber* instancesCountNum_ = @( --instancesCount_ );
        self->_instancesNumberByClassName[ className_ ] = instancesCountNum_;
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
    return result_;
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
        NSNumber* number_ = self->_instancesNumberByClassName[ className_ ];
        if ( !number_ )
        {
            self->_instancesNumberByClassName[ className_ ] = @0;

            {
                BOOL methodAdded_ = [ [ self class ] addClassMethodIfNeedWithSelector: @selector( alloCWithZoneToAdding: )
                                                                              toClass: class_
                                                                    newMethodSelector: @selector( allocWithZone: ) ];

                if ( !methodAdded_ )
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
        NSString* className_ = NSStringFromClass( class_ );
        NSNumber* number_ = self->_instancesNumberByClassName[ className_ ];
        return [ number_ unsignedIntValue ];
    }
}

@end

@implementation NSObject (InstancesCount)

+(void)enableInstancesCounting
{
    [ [ JFFNSObjectInstancesCounter sharedObjectInstancesCounter ] enableInstancesCountingForClass: [ self class ] ];
}

+(NSUInteger)instancesCount
{
    return [ [ JFFNSObjectInstancesCounter sharedObjectInstancesCounter ] instancesCountForClass: [ self class ] ];
}

@end
