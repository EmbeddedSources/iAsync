#import "JFFMutableAssignDictionary.h"

#import "JFFAssignProxy.h"

#import "NSObject+OnDeallocBlock.h"
#import "NSArray+BlocksAdditions.h"

#include "JFFUtilsBlockDefinitions.h"

#import "JFFClangLiterals.h"

@interface JFFAutoRemoveFromDictAssignProxy : JFFAssignProxy

@property ( nonatomic, copy ) JFFSimpleBlock onDeallocBlock;

@end

@implementation JFFAutoRemoveFromDictAssignProxy

-(void)onAddToMutableAssignDictionary:( JFFMutableAssignDictionary* )dict_
                                  key:( id )key_
{
    __unsafe_unretained JFFMutableAssignDictionary* unretainedDict_ = dict_;
    self.onDeallocBlock = ^void( void )
    {
        [ unretainedDict_ removeObjectForKey: key_ ];
    };
    [ self.target addOnDeallocBlock: self.onDeallocBlock ];
}

-(void)onRemoveFromMutableAssignDictionary:( JFFMutableAssignDictionary* )array_
{
    [ self.target removeOnDeallocBlock: self.onDeallocBlock ];
    self.onDeallocBlock = nil;
}

@end

@interface JFFMutableAssignDictionary ()

@property ( nonatomic ) NSMutableDictionary* mutableDictionary;

@end

@implementation JFFMutableAssignDictionary

-(void)dealloc
{
    [ self removeAllObjects ];
}

-(void)removeAllObjects
{
    [ self->_mutableDictionary enumerateKeysAndObjectsUsingBlock: ^( id key
                                                             , JFFAutoRemoveFromDictAssignProxy* proxy_
                                                             , BOOL* stop )
    {
        [  proxy_ onRemoveFromMutableAssignDictionary: self ];
    } ];
    [ self->_mutableDictionary removeAllObjects ];
}

-(NSMutableDictionary*)mutableDictionary
{
    if ( !self->_mutableDictionary )
    {
        self->_mutableDictionary = [ NSMutableDictionary new ];
    }
    return self->_mutableDictionary;
}

-(NSUInteger)count
{
    return [ self->_mutableDictionary count ];
}

-(id)objectForKey:( id )key_
{
    JFFAutoRemoveFromDictAssignProxy* proxy_ = self->_mutableDictionary[ key_ ];
    return proxy_.target;
}

-(id)objectForKeyedSubscript:( id )key_
{
    return [ self objectForKey: key_ ];
}

-(void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block_
{
    [ self->_mutableDictionary enumerateKeysAndObjectsUsingBlock: ^( id key_
                                                                    , JFFAutoRemoveFromDictAssignProxy* proxy_
                                                                    , BOOL* stop_ )
    {
        block_( key_, proxy_.target, stop_ );
    } ];
}

-(NSDictionary*)map:( JFFDictMappingBlock )block_
{
    NSMutableDictionary* result_ = [ [ NSMutableDictionary alloc ] initWithCapacity: [ self count ] ];
    [ self enumerateKeysAndObjectsUsingBlock: ^( id key_, id object_, BOOL* stop_ )
    {
        id newObject_ = block_( key_, object_ );
        if ( newObject_ )
            result_[ key_ ] = newObject_;
    } ];
    return [ result_ copy ];
}

-(void)removeObjectForKey:( id )key_
{
    JFFAutoRemoveFromDictAssignProxy* proxy_ = self->_mutableDictionary[ key_ ];
    [ proxy_ onRemoveFromMutableAssignDictionary: self ];
    [ self->_mutableDictionary removeObjectForKey: key_ ];
}

-(void)setObject:( id )object_ forKey:( id )key_
{
    id previous_object_ = self[ key_ ];
    if ( previous_object_ )
    {
        [ self removeObjectForKey: key_ ];
    }

    JFFAutoRemoveFromDictAssignProxy* proxy_ = [ [ JFFAutoRemoveFromDictAssignProxy alloc ] initWithTarget: object_ ];
    self.mutableDictionary[ key_ ] = proxy_;
    [ proxy_ onAddToMutableAssignDictionary: self key: key_ ];
}

-(void)setObject:( id )newValue_ forKeyedSubscript:( id )key_
{
    [ self setObject: newValue_ forKey: key_ ];
}

-(NSString*)description
{
    return [ self->_mutableDictionary description ];
}

@end
