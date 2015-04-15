#import <Foundation/Foundation.h>

@interface JNUtils : NSObject

+(NSDictionary*)headersDictionadyWithContentType:( NSString* )content_type_;
+(NSDictionary*)headersDictionadyWithUploadContentType;

+(NSString*)utf8XmlContentType;
+(NSDictionary*)headersDictionadyWithUtf8XmlContentType;

@end
