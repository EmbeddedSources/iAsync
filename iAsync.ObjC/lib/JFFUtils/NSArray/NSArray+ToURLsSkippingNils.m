#import "NSArray+ToURLsSkippingNils.h"

#import "NSString+ToURL.h"
#import "NSObject+NsNullAsNil.h"
#import "NSArray+BlocksAdditions.h"

@implementation NSArray (ToURLsSkippingNils)

- (instancetype)toURLsSkippingNils
{
    return [self forceMap:^id(id object) {
        
        return [[object nsNullAsNil] toURL];
    }];
}

@end
