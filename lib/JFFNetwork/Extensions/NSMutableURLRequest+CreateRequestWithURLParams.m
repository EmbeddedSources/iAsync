#import "NSMutableURLRequest+CreateRequestWithURLParams.h"

#import "JNNsUrlConnection.h"
#import "JFFURLConnectionParams.h"

@implementation NSMutableURLRequest (CreateRequestWithURLParams)

+(id)newMutableURLRequestWithParams:( JFFURLConnectionParams* )params_
{
    static const NSTimeInterval timeout_ = 60.;
    NSMutableURLRequest* request_ = [ self requestWithURL: params_.url
                                              cachePolicy: NSURLRequestReloadIgnoringLocalCacheData 
                                          timeoutInterval: timeout_ ];

    NSString* httpMethod_ = params_.httpMethod ?: @"GET";
    if ( !params_.httpMethod && params_.httpBody )
    {
        httpMethod_ = @"POST";
    }

    [ request_ setHTTPBody           : params_.httpBody ];
    [ request_ setAllHTTPHeaderFields: params_.headers  ];
    [ request_ setHTTPMethod         : httpMethod_      ];

    return request_;
}

@end
