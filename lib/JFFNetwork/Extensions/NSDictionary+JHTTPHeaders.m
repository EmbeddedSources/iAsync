#import "NSDictionary+JHTTPHeaders.h"

@implementation NSDictionary (JHTTPHeaders)

-(id)initWithContentType:( NSString* )contentType_
{
    NSParameterAssert( contentType_ );

    id objects_[] = { contentType_    };
    id keys_   [] = { @"Content-Type" };

    return [ self initWithObjects: objects_ forKeys: keys_ count: 1 ];
}

+(id)headersDictionadyWithUploadContentType
{
    return [ [ self alloc ] initWithContentType: @"application/x-www-form-urlencoded" ];
}

#pragma mark -
#pragma mark UTF8 xml
+(NSString*)utf8XmlContentType
{
    return @"application/xml;charset=utf-8";
}

+(id)headersDictionadyWithUtf8XmlContentType
{
    return [ [ self alloc ] initWithContentType: [ self utf8XmlContentType ] ];
}

@end
