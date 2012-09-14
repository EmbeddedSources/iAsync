#import "FoursquareCheckinsModel.h"

@interface FoursquareCheckinsModel (APIParser)

+ (id)fqCheckinModelWithDict:(NSDictionary *)dict error:(NSError **)outError;

@end
