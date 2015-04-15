#import <Foundation/Foundation.h>

@interface NSNumber (FSStorable)

+ (instancetype)newIntNumberWithContentsOfFile:(NSString *)fileName;
+ (instancetype)newDoubleWithContentsOfFile:(NSString *)fileName;

- (BOOL)saveNumberToFile:(NSString *)fileName;

@end
