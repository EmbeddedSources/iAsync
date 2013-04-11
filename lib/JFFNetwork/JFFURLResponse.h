#import <JFFNetwork/JNUrlResponse.h>
#import <Foundation/Foundation.h>

@interface JFFURLResponse : NSObject< JNUrlResponse >

@property (nonatomic) NSInteger statusCode;
@property (nonatomic) NSDictionary* allHeaderFields;
@property (nonatomic) NSURL* url;

@property (nonatomic, readonly) unsigned long long expectedContentLength;

@end
