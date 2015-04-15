#import <Foundation/Foundation.h>

@interface NSDictionary (JHTTPHeaders)

- (instancetype)initWithContentType:(NSString *)contentType;
+ (instancetype)headersDictionadyWithUploadContentType;

+ (NSString *)utf8XmlContentType;
+ (instancetype)headersDictionadyWithUtf8XmlContentType;

@end
