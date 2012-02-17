#import "JNUtils.h"

@implementation JNUtils

+(NSDictionary*)headersDictionadyWithContentType:( NSString* )content_type_
{
   return [ NSDictionary dictionaryWithObject: content_type_
                                       forKey: @"Content-Type" ];
}

+(NSDictionary*)headersDictionadyWithUploadContentType
{
   return [ self headersDictionadyWithContentType: @"application/x-www-form-urlencoded" ];
}

#pragma mark -
#pragma mark UTF8 xml
+(NSString*)utf8XmlContentType
{
   return @"application/xml;charset=utf-8";
}

+(NSDictionary*)headersDictionadyWithUtf8XmlContentType
{
   return [ self headersDictionadyWithContentType: [ self utf8XmlContentType ] ];
}

@end
