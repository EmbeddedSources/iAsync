#import "FoursquareUserModel.h"

@interface FoursquareUserModel (APIParser)

+ (instancetype)fqUserModelWithDict:(NSDictionary *)dict error:(NSError **)outError;

@end
