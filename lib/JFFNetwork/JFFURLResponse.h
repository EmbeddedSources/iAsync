#import <JFFNetwork/JNUrlResponse.h>
#import <Foundation/Foundation.h>

@interface JFFURLResponse : NSObject< JNUrlResponse >

@property ( nonatomic ) NSInteger statusCode;
@property ( nonatomic, strong ) NSDictionary* allHeaderFields;
@property ( nonatomic, strong ) NSURL* url;

@property ( nonatomic, readonly ) long long expectedContentLength;

@end
