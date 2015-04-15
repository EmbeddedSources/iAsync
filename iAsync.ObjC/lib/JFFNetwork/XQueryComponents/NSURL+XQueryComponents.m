#import "NSURL+XQueryComponents.h"

#import "NSString+XQueryComponents.h"

@implementation NSURL (XQueryComponents)

- (NSDictionary *)queryComponents
{
    return [[self query] dictionaryFromQueryComponents];
}

@end
