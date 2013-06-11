#import "NSData+DataForHTTPPost.h"

@implementation NSData (DataForHTTPPost)

+ (instancetype)dataForHTTPPostWithData:(NSData *)data
                            andFileName:(NSString *)fileName
                       andParameterName:(NSString *)parameter
                               boundary:(NSString *)boundary
{
    NSMutableData *result = [[self alloc] initWithCapacity:[data length] + 512];
    [result appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameter, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [result appendData:data];
    
    [result appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return result;
}

@end

@implementation NSMutableData (DataForHTTPPost)

- (void)appendHTTPParameters:(NSDictionary *)parameters
                    boundary:(NSString *)boundary
{
    if (!parameters) {
        return;
    }
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        [self appendData:[[[NSString alloc] initWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [self appendData:[[[NSString alloc] initWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [self appendData:[[obj description] dataUsingEncoding:NSUTF8StringEncoding]];
        [self appendData:[[[NSString alloc] initWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
}

@end
