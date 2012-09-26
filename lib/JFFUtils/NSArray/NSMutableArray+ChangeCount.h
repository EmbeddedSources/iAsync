#import <Foundation/Foundation.h>

@interface NSMutableArray (ChangeCount)

- (void)shrinkToSize:(NSUInteger)newSize;

@end
