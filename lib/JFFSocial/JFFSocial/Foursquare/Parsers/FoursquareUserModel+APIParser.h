#import "FoursquareUserModel.h"

@interface FoursquareUserModel (APIParser)

+ (id)fqUserModelWithDict:(NSDictionary *)dict error:(NSError **)outError;

@end
