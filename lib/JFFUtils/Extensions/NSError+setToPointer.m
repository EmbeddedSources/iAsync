#import "NSError+setToPointer.h"

@implementation NSError (setToPointer)

-(BOOL)setToPointer:( NSError** )outError_
{
    if ( NULL == outError_ )
    {
        return NO;
    }

    *outError_ = self;
    return YES;
}

@end
