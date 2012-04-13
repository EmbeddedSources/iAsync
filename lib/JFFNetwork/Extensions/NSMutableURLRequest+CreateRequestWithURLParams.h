#import <Foundation/Foundation.h>

@class JFFURLConnectionParams;

@interface NSMutableURLRequest (CreateRequestWithURLParams)

+(id)newMutableURLRequestWithParams:( JFFURLConnectionParams* )params_;

@end
