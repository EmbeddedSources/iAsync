#import <Foundation/Foundation.h>

@interface NSData (DataForHTTPPost)

+ (instancetype)dataForHTTPPostWithData:(NSData *)data
                            andFileName:(NSString *)fileName
                       andParameterName:(NSString *)parameter
                               boundary:(NSString *)boundary;

@end

@interface NSMutableData (DataForHTTPPost)

- (void)appendHTTPParameters:(NSDictionary *)parameters
                    boundary:(NSString *)boundary;

@end
