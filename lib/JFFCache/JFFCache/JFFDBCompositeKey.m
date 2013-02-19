#import "JFFDBCompositeKey.h"

#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>

@interface JFFDBCompositeKey ()

@property (nonatomic) NSMutableArray *keys;

@end

@implementation JFFDBCompositeKey

- (id)copyWithZone:(NSZone *)zone
{
    JFFDBCompositeKey *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_keys = [_keys copyWithZone:zone];
    }
    
    return copy;
}

- (NSUInteger)hash
{
    return [self.keys hash];
}

- (BOOL)isEqual:(id)object
{
    JFFDBCompositeKey *otherObject = object;
    return [otherObject.keys isEqual:self.keys];
}

- (id)initWithKeys:(NSArray *)keys
{
    NSParameterAssert([keys isKindOfClass:[NSArray class]]);
    
    self = [super init];
    
    if (self) {
        self->_keys = [keys copy];
    }
    
    return self;
}

+ (id)compositeKeyWithKeys:(NSString *)key, ...
{
    NSMutableArray *keys = [NSMutableArray new];
    va_list args;
    va_start(args, key);
    for (NSString *currentKey = key; currentKey != nil; currentKey = va_arg(args, NSString*)) {
        [keys addObject:currentKey];
    }
    va_end( args );
    
    return [[self alloc] initWithKeys:keys];
}

+ (id)compositeKeyWithKey:(JFFDBCompositeKey *)compositeKey forIndexes:(NSIndexSet *)indexes
{
    NSUInteger size = [compositeKey.keys count];
    NSArray *newKeys = [NSArray arrayWithSize:size producer:^id(NSUInteger index) {
        return [indexes containsIndex:index]
        ?compositeKey.keys[index]
        :@"%";
    }];
    
    return [[JFFDBCompositeKey alloc] initWithKeys:newKeys];
}

- (NSString *)toCompositeKey
{
    return [self.keys componentsJoinedByString:@"_"];
}

@end
