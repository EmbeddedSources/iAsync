#import <Foundation/Foundation.h>

@interface NSError (setToPointer)

- (BOOL)setToPointer:(NSError **)outError;

@end
