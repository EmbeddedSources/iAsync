#import <Foundation/Foundation.h>

@interface NSString (Base64)

+ (instancetype)base64StringFromData:(NSData *)data length:(int)length;

@end
