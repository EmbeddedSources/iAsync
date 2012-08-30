#import <JFFNetwork/JNUrlConnectionCallbacks.h>

#import <Foundation/Foundation.h>

@class JFFLocalCookiesStorage;

@interface JFFURLConnectionParams : NSObject

@property ( nonatomic, strong ) NSURL* url;
@property ( nonatomic, strong ) NSData* httpBody;
@property ( nonatomic, strong ) NSString* httpMethod;
@property ( nonatomic, strong ) NSDictionary* headers;
@property ( nonatomic ) BOOL useLiveConnection; 
@property ( nonatomic, strong ) JFFLocalCookiesStorage* cookiesStorage;
@property ( nonatomic, copy   ) JFFShouldAcceptCertificateForHost certificateCallback;

@end
