//can not be under arc
#import "NSObject+InstancesCount.h"

#import <JFFUtils/Blocks/JFFOnDeallocBlockOwner.h>
#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>
#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/JFFClangLiterals.h>

@interface JFFNSObjectInstancesCounter : NSObject

@property (nonatomic, retain) NSMutableDictionary *instancesNumberByClassName;

@end

@implementation JFFNSObjectInstancesCounter

- (void)dealloc
{
    [_instancesNumberByClassName release];
    
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _instancesNumberByClassName = [NSMutableDictionary new];
    }
    
    return self;
}

+ (instancetype)sharedObjectInstancesCounter
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = [[self class] new];});
    return instance;
}

- (void)incrementInstancesCountForClass:(Class)class
{
    @synchronized(self) {
        NSString *className = NSStringFromClass(class);
        NSNumber *number    = _instancesNumberByClassName[className];
        NSUInteger instancesCount = [number unsignedIntValue];
        NSNumber* instancesCountNum = @(++instancesCount);
        _instancesNumberByClassName[className] = instancesCountNum;
    }
}

- (void)decrementInstancesCountForClass:(Class)class
{
    @synchronized(self) {
        NSString *className = NSStringFromClass(class);
        NSNumber *number    = _instancesNumberByClassName[className];
        NSUInteger instancesCount   = [number unsignedIntValue];
        NSNumber* instancesCountNum = @(--instancesCount);
        _instancesNumberByClassName[className] = instancesCountNum;
    }
}

+ (void)incrementInstancesCountForClass:(Class)class
{
    [[JFFNSObjectInstancesCounter sharedObjectInstancesCounter] incrementInstancesCountForClass:class];
}

+ (void)decrementInstancesCountForClass:(Class)class
{
    [[JFFNSObjectInstancesCounter sharedObjectInstancesCounter] decrementInstancesCountForClass:class];
}

+ (id)instancesCounterAllocatorForClass:(Class)class
                          nativeAllocor:(id(^)(void))native
{
    [JFFNSObjectInstancesCounter incrementInstancesCountForClass:class];
    NSObject *result = native();
    [result addOnDeallocBlock:^void(void) {
        [JFFNSObjectInstancesCounter decrementInstancesCountForClass:class];
    }];
    return result;
}

+ (id)allocWithZoneHook
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (id)alloCWithZonePrototype
{
    return [JFFNSObjectInstancesCounter instancesCounterAllocatorForClass:[self class]
                                                            nativeAllocor:^id(void) {
                                                                
        return [self allocWithZoneHook];
    }];
}

+ (id)alloCWithZoneToAdding
{
    return [JFFNSObjectInstancesCounter instancesCounterAllocatorForClass:[self class]
                                                            nativeAllocor:^id(void) {
        
        return [super alloc];
    }];
}

- (void)enableInstancesCountingForClass:(Class)class
{
    @synchronized(self) {
        
        NSString *className = NSStringFromClass(class);
        NSNumber *number = _instancesNumberByClassName[className];
        if (!number) {
            
            _instancesNumberByClassName[className] = @0;
            
            {
                BOOL methodAdded = [[self class] addClassMethodIfNeedWithSelector:@selector(alloCWithZoneToAdding)
                                                                          toClass:class
                                                                newMethodSelector:@selector(alloc)];
                
                if (!methodAdded) {
                    // create name allocWithZoneHook dynamicaly and allocWithZonePrototype use block instead
                    [[self class] hookClassMethodForClass:class
                                             withSelector:@selector(alloc)
                                  prototypeMethodSelector:@selector(alloCWithZonePrototype)
                                       hookMethodSelector:@selector(allocWithZoneHook)];
                }
            }
        }
    }
}

- (NSUInteger)instancesCountForClass:(Class)class
{
    @synchronized(self)
    {
        NSString *className = NSStringFromClass(class);
        NSNumber *number = _instancesNumberByClassName[className];
        return [number unsignedIntValue];
    }
}

@end

@implementation JFFOnDeallocBlockOwner (InstancesCount)

+ (void)enableInstancesCounting
{
    NSAssert(NO, @"Can not enable enstances counting for this class");
}

@end

@implementation NSObject (InstancesCount)

+ (void)enableInstancesCounting
{
    [[JFFNSObjectInstancesCounter sharedObjectInstancesCounter] enableInstancesCountingForClass:[self class]];
}

+ (NSUInteger)instancesCount
{
    return [[JFFNSObjectInstancesCounter sharedObjectInstancesCounter] instancesCountForClass:[self class]];
}

@end
