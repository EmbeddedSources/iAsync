#import <Foundation/Foundation.h>

@interface JFFUrlResponseLogger : NSObject 

/**
 @param url_response_ -- conforms to the JNUrlResponse protocol. The protocol is omitted for the NSHTTPURLResponse compatibility.
 */
+(NSString*)descriptionStringForUrlResponse:(id /*< JNUrlResponse >*/)url_response_;
+(NSString*)dumpHttpHeaderFields:(NSDictionary*)all_header_fields_;

@end
