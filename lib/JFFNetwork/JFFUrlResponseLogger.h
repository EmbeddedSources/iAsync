#import <Foundation/Foundation.h>

@interface JFFUrlResponseLogger : NSObject 

/**
 @param urlResponse -- conforms to the JNUrlResponse protocol. The protocol is omitted for the NSHTTPURLResponse compatibility.
 */
+ (NSString *)descriptionStringForUrlResponse:(id /*< JNUrlResponse >*/)urlResponse;
+ (NSString *)dumpHttpHeaderFields:(NSDictionary *)allHeaderFields;

@end
