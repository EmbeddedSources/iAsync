#import "NSData+DataForHTTPPost.h"

@implementation NSData (DataForHTTPPost)

+ (NSData *)dataForHTTPPostWithData:(NSData *)data
                        andFileName:(NSString *)fileName
                   andParameterName:(NSString *)parameter
                           boundary:(NSString *)boundary
{
    NSData *result = [self mutableDataForHTTPPostWithData:data
                                              andFileName:fileName
                                         andParameterName:parameter
                                                 boundary:boundary];
    return [result copy];
}

+ (NSData *)mutableDataForHTTPPostWithData:(NSData *)data
                               andFileName:(NSString *)fileName
                          andParameterName:(NSString *)parameter
                                  boundary:(NSString *)boundary
{
    NSMutableData *body = [[NSMutableData alloc] initWithCapacity:[data length] + 512];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameter, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[NSData dataWithData:data]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [body copy];
    
}

- (NSData *)dataForHTTPPostByAppendingParameters:(NSDictionary *)parameters
                                        boundary:(NSString *)boundary
{
    if (!parameters) {
        return self;
    }
    
    NSMutableData *newData = [self mutableCopy];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        [newData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [newData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [newData appendData:[[obj description] dataUsingEncoding:NSUTF8StringEncoding]];
        [newData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    return [newData copy];
}

@end
