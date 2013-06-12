#import "JFFOnDeallocBlockOwner.h"

@implementation JFFOnDeallocBlockOwner

- (instancetype)initWithBlock:(JFFSimpleBlock)block
{
    self = [super init];
    
    if (self) {
        NSParameterAssert(block);
        _block = [block copy];
    }
    
    return self;
}

- (void)dealloc
{
    if (_block)
        _block();
}

@end
