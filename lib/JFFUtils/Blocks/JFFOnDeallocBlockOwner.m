#import "JFFOnDeallocBlockOwner.h"

@implementation JFFOnDeallocBlockOwner

@synthesize block = _block;

-(id)initWithBlock:( JFFSimpleBlock )block_
{
    self = [ super init ];

    NSParameterAssert( block_ );
    _block = block_;

    return self;
}

-(void)dealloc
{
    if ( _block )
    {
        _block();
        _block = nil;//JTODO may be bug
    }
}

@end
