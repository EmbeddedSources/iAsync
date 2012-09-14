#import <Foundation/Foundation.h>

//TODO: ADD creating boundary
#define BOUNDARY_STRING @"0xKhTmLbOuNdArY"

@interface NSData (DataForHTTPPost)

+ (NSData *)dataForHTTPPostWithData:(NSData *)data andFileName:(NSString *)fileName andParameterName:(NSString *)parameter;

+ (NSData *)mutableDataForHTTPPostWithData:(NSData *)data andFileName:(NSString *)fileName andParameterName:(NSString *)parameter;

- (NSData *)dataForHTTPPostByAppendingParameters:(NSDictionary *)parameters;

@end
