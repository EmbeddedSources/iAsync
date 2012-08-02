#import "NSURL+CPlusPlus.h"
#import "NSString+CPlusPlus.h"

@implementation NSURL (CPlusPlus)

-(std::string)toStlString
{
    return [ [ self absoluteString ] toStlString ];
}

@end
