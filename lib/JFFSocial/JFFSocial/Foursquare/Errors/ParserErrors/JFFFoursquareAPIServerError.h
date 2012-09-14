#import <JFFSocial/Errors/JFFSocialError.h>

@interface JFFFoursquareAPIServerError : JFFSocialError

- (id)initWithDictionary:(NSDictionary *)errorDict;

@end
