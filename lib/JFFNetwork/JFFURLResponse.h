#import <JFFNetwork/JNUrlResponse.h>
#import <Foundation/Foundation.h>

@interface JFFURLResponse : NSObject< JNUrlResponse >

@property ( nonatomic, assign ) NSInteger statusCode;
@property ( nonatomic, strong ) NSDictionary* allHeaderFields;

@property ( nonatomic, assign, readonly ) long long expectedContentLength;

@end
