#import <Foundation/Foundation.h>

@interface NSDictionary (JHTTPHeaders)

- (id)initWithContentType:(NSString *)contentType;
+ (id)headersDictionadyWithUploadContentType;

+ (NSString *)utf8XmlContentType;
+ (id)headersDictionadyWithUtf8XmlContentType;

@end
