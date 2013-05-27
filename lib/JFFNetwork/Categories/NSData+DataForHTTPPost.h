#import <Foundation/Foundation.h>

@interface NSData (DataForHTTPPost)

+ (NSData *)dataForHTTPPostWithData:(NSData *)data
                        andFileName:(NSString *)fileName
                   andParameterName:(NSString *)parameter
                           boundary:(NSString *)boundary;

+ (NSData *)mutableDataForHTTPPostWithData:(NSData *)data
                               andFileName:(NSString *)fileName
                          andParameterName:(NSString *)parameter
                                  boundary:(NSString *)boundary;

- (NSData *)dataForHTTPPostByAppendingParameters:(NSDictionary *)parameters
                                        boundary:(NSString *)boundary;

@end
