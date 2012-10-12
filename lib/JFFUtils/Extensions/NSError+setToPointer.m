#import "NSError+setToPointer.h"

@implementation NSError (setToPointer)

- (BOOL)setToPointer:(NSError *__autoreleasing *)outError
{
    if (NULL == outError) {
        return NO;
    }
    
    *outError = self;
    return YES;
}

@end
