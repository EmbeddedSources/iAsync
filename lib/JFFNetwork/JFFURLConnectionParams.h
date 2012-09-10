#import <JFFNetwork/JNUrlConnectionCallbacks.h>

#import <Foundation/Foundation.h>

@class JFFLocalCookiesStorage;

@interface JFFURLConnectionParams : NSObject< NSCopying >

@property ( nonatomic ) NSURL* url;
@property ( nonatomic ) NSData* httpBody;
@property ( nonatomic ) NSString* httpMethod;
@property ( nonatomic ) NSDictionary* headers;
@property ( nonatomic ) BOOL useLiveConnection; 
@property ( nonatomic ) JFFLocalCookiesStorage* cookiesStorage;
@property ( nonatomic, copy ) JFFShouldAcceptCertificateForHost certificateCallback;

@end
