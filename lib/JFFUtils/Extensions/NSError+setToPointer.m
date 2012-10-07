#import "NSError+setToPointer.h"

@implementation NSError (setToPointer)

- (BOOL)setToPointer:(NSError **)outError
{
    if (NULL == outError) {
        return NO;
    }
    
    *outError = self;
    return YES;
}

@end
