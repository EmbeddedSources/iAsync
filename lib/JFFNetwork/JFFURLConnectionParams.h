#import <JFFNetwork/JNUrlConnectionCallbacks.h>

#import <Foundation/Foundation.h>

typedef NSInputStream *(^JFFInputStreamBuilder)(void);

@class JFFLocalCookiesStorage;

@interface JFFURLConnectionParams : NSObject<NSCopying>

@property (nonatomic) NSURL         *url;
@property (nonatomic) NSData        *httpBody;
@property (nonatomic, strong) NSInputStream *httpBodyStream;//TODO remove this property and use "httpBodyStreamBuilder" instead of
@property (nonatomic) NSString      *httpMethod;
@property (nonatomic) NSDictionary  *headers;
@property (nonatomic) BOOL           useLiveConnection;
@property (nonatomic) long long      totalBytesExpectedToWrite;
@property (nonatomic) JFFLocalCookiesStorage *cookiesStorage;

@property (nonatomic, copy) JFFInputStreamBuilder             httpBodyStreamBuilder;
@property (nonatomic, copy) JFFShouldAcceptCertificateForHost certificateCallback;

@end
