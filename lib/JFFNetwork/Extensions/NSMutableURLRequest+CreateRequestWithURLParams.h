#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

@interface NSMutableURLRequest (CreateRequestWithURLParams)

+(id)mutableURLRequestWithParams:( JFFURLConnectionParams* )params_;

@end
