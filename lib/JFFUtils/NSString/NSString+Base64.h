#import <Foundation/Foundation.h>

@interface NSString (Base64)

+(NSString*)base64StringFromData:( NSData* )data length:( int )length;

@end
