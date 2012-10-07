#import "JFFDBCompositeKey.h"

#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>

@interface JFFDBCompositeKey ()

@property ( nonatomic ) NSMutableArray* keys;

@end

@implementation JFFDBCompositeKey

-(id)copyWithZone:( NSZone* )zone_
{
    JFFDBCompositeKey* copy_ = [ [ [ self class ] allocWithZone: zone_ ] init ];

    if ( copy_ )
    {
        copy_->_keys = [ self->_keys copyWithZone: zone_ ];
    }

    return copy_;
}

-(NSUInteger)hash
{
    return [ self.keys hash ];
}

-(BOOL)isEqual:( id )object_
{
    JFFDBCompositeKey* otherObject_ = object_;
    return [ otherObject_.keys isEqual: self.keys ];
}

- (id)initWithKeys:(NSArray *)keys
{
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
