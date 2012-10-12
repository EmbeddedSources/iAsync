#import "NSArray+FqCheckinsAPIParser.h"

#import "NSDictionary+FqAPIresponseParser.h"
#import "FoursquareCheckinsModel+APIParser.h"

#import "JFFFoursquaerAPIInvalidresponseError.h"

@implementation NSArray (FqCheckinsAPIParser)

+ (NSArray *)fqCheckinsWithDict:(NSDictionary *)response error:(NSError **)outError
{
    NSArray *friendsArray = [[response dictionaryForKey:@"checkins"] arrayForKey:@"items"];
    
    if (friendsArray) {
        friendsArray = [friendsArray map:^id(NSDictionary *object, NSError *__autoreleasing *outError) {
            
            FoursquareCheckinsModel *checkinModel = [FoursquareCheckinsModel fqCheckinModelWithDict:object error:outError];
            return checkinModel;
            
        } error:outError];
    }
    else
    {
        [[JFFFoursquaerAPIInvalidresponseError new] setToPointer:outError];
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
