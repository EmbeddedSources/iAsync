#import "FoursquareCheckinsModel.h"

@interface FoursquareCheckinsModel (APIParser)

+ (instancetype)fqCheckinModelWithDict:(NSDictionary *)dict error:(NSError **)outError;

@end
