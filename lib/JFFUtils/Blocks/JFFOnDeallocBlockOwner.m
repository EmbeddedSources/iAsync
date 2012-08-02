#import "JFFOnDeallocBlockOwner.h"

@implementation JFFOnDeallocBlockOwner

-(id)initWithBlock:( JFFSimpleBlock )block_
{
    self = [ super init ];

    NSParameterAssert( block_ );
    self->_block = [ block_ copy ];

    return self;
}

-(void)dealloc
{
    if ( self->_block )
        self->_block();
}

@end
