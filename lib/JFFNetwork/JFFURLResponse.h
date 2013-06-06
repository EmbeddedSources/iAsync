#import <JFFNetwork/JNUrlResponse.h>
#import <Foundation/Foundation.h>

@interface JFFURLResponse : NSObject< JNUrlResponse >

@property ( nonatomic ) NSInteger statusCode;
@property ( nonatomic, strong ) NSDictionary* allHeaderFields;
@property ( nonatomic, strong ) NSURL* url;

@property (nonatomic, readonly) unsigned long long expectedContentLength;

@property ( nonatomic, readonly ) NSString* contentEncoding;

@end
