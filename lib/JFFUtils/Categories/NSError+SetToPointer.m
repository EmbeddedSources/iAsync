#import "NSError+SetToPointer.h"

@implementation NSError (SetToPointer)

- (BOOL)setToPointer:(NSError *__autoreleasing *)outError
{
    if (NULL == outError) {
        return NO;
    }
    
    *outError = self;
    return YES;
}

@end
