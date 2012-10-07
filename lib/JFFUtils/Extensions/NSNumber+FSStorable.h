#import <Foundation/Foundation.h>

@interface NSNumber (FSStorable)

+ (id)newLongLongNumberWithContentsOfFile:(NSString *)fileName;

- (BOOL)saveNumberToFile:(NSString *)fileName;

@end
