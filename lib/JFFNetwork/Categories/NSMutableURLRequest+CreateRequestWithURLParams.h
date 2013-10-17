#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

@interface NSMutableURLRequest (CreateRequestWithURLParams)

+ (instancetype)mutableURLRequestWithParams:(JFFURLConnectionParams *)params;

@end
