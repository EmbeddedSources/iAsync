//can not be under arc
#import "NSObject+InstancesCount.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>
#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>

@interface JFFNSObjectInstancesCounter : NSObject

//JTODO try use ivar instead of property
@property ( nonatomic, retain ) NSMutableDictionary* instancesNumberByClassName;

@end

@implementation JFFNSObjectInstancesCounter

@synthesize instancesNumberByClassName = _instancesNumberByClassName;

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        self.instancesNumberByClassName = [ NSMutableDictionary dictionary ];
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
        NSString* class_name_ = NSStringFromClass( class_ );
        NSNumber* number_ = [ self.instancesNumberByClassName objectForKey: class_name_ ];
        NSUInteger instances_count_  = [ number_ unsignedIntValue ];
        NSNumber* instancesCountNum_ = [ NSNumber numberWithUnsignedInteger: ++instances_count_ ];
        [ self.instancesNumberByClassName setObject: instancesCountNum_
                                             forKey: class_name_ ];
    }
}

-(void)decrementInstancesCountForClass:( Class )class_
{
    @synchronized( self )
    {
        NSString* class_name_ = NSStringFromClass( class_ );
        NSNumber* number_ = [ self.instancesNumberByClassName objectForKey: class_name_ ];
        NSUInteger instances_count_  = [ number_ unsignedIntValue ];
        NSNumber* instancesCountNum_ = [ NSNumber numberWithUnsignedInteger: --instances_count_ ];
        [ self.instancesNumberByClassName setObject: instancesCountNum_
                                             forKey: class_name_ ];
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
        NSString* class_name_ = NSStringFromClass( class_ );
        NSNumber* number_ = [ self.instancesNumberByClassName objectForKey: class_name_ ];
        if ( !number_ )
        {
            [ self.instancesNumberByClassName setObject: [ NSNumber numberWithInteger: 0 ] forKey: class_name_ ];

            {
                BOOL method_added_ = [ [ self class ] addClassMethodIfNeedWithSelector: @selector( alloCWithZoneToAdding: )
                                                                               toClass: class_
                                                                     newMethodSelector: @selector( allocWithZone: ) ];

                if ( !method_added_ )
                {
                    //JTODO create name allocWithZoneHook dynamicaly and allocWithZonePrototype use block instead
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
        NSNumber* number_ = [ self.instancesNumberByClassName objectForKey: class_name_ ];
        #ifdef DEBUG
            NSAssert( number_, @"instances counting not enabled for this class" );
        #endif
        return [ number_ unsignedIntValue ];
    }
}

@end

@implementation NSObject (InstancesCount)

+(void)enableInstancesCounting
{
//JTODO fix for release mode also
#ifdef DEBUG
    [ [ JFFNSObjectInstancesCounter sharedObjectInstancesCounter ] enableInstancesCountingForClass: [ self class ] ];
#endif
}

+(NSUInteger)instancesCount
{
    return [ [ JFFNSObjectInstancesCounter sharedObjectInstancesCounter ] instancesCountForClass: [ self class ] ];
}

@end
