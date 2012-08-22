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

-(id)initWithKeys:( NSArray* )keys_
{
    self = [ super init ];

    if ( self )
    {
        self->_keys = [ keys_ copy ];
    }

    return self;
}

+(id)compositeKeyWithKeys:( NSString* )key_, ...
{
    NSMutableArray* keys_ = [ NSMutableArray new ];
    va_list args;
    va_start( args, key_ );
    for ( NSString* currentKey_ = key_; currentKey_ != nil; currentKey_ = va_arg( args, NSString* ) )
    {
        [ keys_ addObject: currentKey_ ];
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
                    ? compositeKey_.keys[ index_ ]
                    : @"%";
    } ];

    return [ [ JFFDBCompositeKey alloc ] initWithKeys: newKeys_ ];
}

-(NSString*)toCompositeKey
{
    return [ self.keys componentsJoinedByString: @"_" ];
}

@end
