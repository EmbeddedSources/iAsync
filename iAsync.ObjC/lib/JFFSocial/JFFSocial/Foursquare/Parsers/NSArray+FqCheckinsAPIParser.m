#import "NSArray+FqCheckinsAPIParser.h"

#import "FoursquareCheckinsModel+APIParser.h"

#import "JFFFoursquaerAPIInvalidresponseError.h"

@implementation NSArray (FqCheckinsAPIParser)

+ (NSArray *)fqCheckinsWithDict:(NSDictionary *)response error:(NSError **)outError
{
    NSArray *friendsArray = [response[@"checkins"] arrayForKey:@"items"];
    
    if (friendsArray) {
        friendsArray = [friendsArray map:^id(NSDictionary *object, NSError *__autoreleasing *outError) {
            
            FoursquareCheckinsModel *checkinModel = [FoursquareCheckinsModel fqCheckinModelWithDict:object error:outError];
            return checkinModel;
            
        } outError:outError];
    }
    else
    {
        if (outError) {
            *outError = [JFFFoursquaerAPIInvalidresponseError new];
        }
    }
    
    return friendsArray;
}
/*

response: {
checkins: {
count: 1
items: [
    ...
        ]
}
}
*/
@end
