#import "JFFDBCompositeKey.h"

#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>

@interface JFFDBCompositeKey ()

@property ( nonatomic, strong ) NSMutableArray* keys;

@end

@implementation JFFDBCompositeKey

@synthesize keys;

-(id)copyWithZone:( NSZone* )zone_
{
    JFFDBCompositeKey* copy_ = [ [ [ self class ] allocWithZone: zone_ ] init ];

    copy_.keys = [ self.keys copyWithZone: zone_ ];

    return copy_;
}

-(NSUInteger)hash
{
    return [ self.keys hash ];
}

-(BOOL)isEqual:( id )object_
{
    JFFDBCompositeKey* other_object_ = object_;
    return [ other_object_.keys isEqual: self.keys ];
}

-(id)initWithKeys:( NSArray* )keys_
{
    self = [ super init ];

    if ( self )
    {
        self.keys = [ NSArray arrayWithArray: keys_ ];
    }

    return self;
}

+(id)compositeKeyWithKeys:( NSString* )key_, ...
{
    NSMutableArray* keys_ = [ NSMutableArray new ];
    va_list args;
    va_start( args, key_ );
    for ( NSString* current_key_ = key_; current_key_ != nil; current_key_ = va_arg( args, NSString* ) )
    {
        [ keys_ addObject: current_key_ ];
    }
    va_end( args );

    return [ [ self alloc ] initWithKeys: keys_ ];
}

+(id)compositeKeyWithKey:( JFFDBCompositeKey* )compositeKey_ forIndexes:( NSIndexSet* )indexes_
{
    NSUInteger size_ = [ compositeKey_.keys count ];
    NSArray* newKeys_ = [ NSArray arrayWithSize: size_ producer: ^id( NSUInteger index_ )
    {
        return [ indexes_ containsIndex: index_ ] 
                    ? [ compositeKey_.keys objectAtIndex: index_ ] 
                    : @"%";
    } ];

    return [ [ JFFDBCompositeKey alloc ] initWithKeys: newKeys_ ];
}

-(NSString*)toCompositeKey
{
    return [ self.keys componentsJoinedByString: @"_" ];
}

@end
