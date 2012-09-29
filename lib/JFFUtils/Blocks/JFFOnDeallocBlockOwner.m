#import "JFFOnDeallocBlockOwner.h"

@implementation JFFOnDeallocBlockOwner

- (id)initWithBlock:(JFFSimpleBlock)block
{
    self = [super init];
    
    if (self) {
        NSParameterAssert(block);
        self->_block = [block copy];
    }
    
    return self;
}

- (void)dealloc
{
    if (self->_block)
        self->_block();
}

@end
