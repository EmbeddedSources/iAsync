#import "FoursquareUserModel+APIParser.h"

@implementation FoursquareUserModel (APIParser)

+ (id)fqUserModelWithDict:(NSDictionary *)dict error:(NSError **)outError
{
    FoursquareUserModel *model = [self new];
    
    model.userID = [dict stringForKey:@"id"];
    model.firstName = [dict stringForKey:@"firstName"];
    model.lastName = [dict stringForKey:@"lastName"];
    model.contacts = [dict dictionaryForKey:@"contact"];
    model.photoURL = [[dict stringForKeyPath:@"photo.prefix"] stringByAppendingString:[dict stringForKeyPath:@"photo.suffix"]];
    
    return model;
}

/*
 {
 id: "31199973"
 firstName: "Artem"
 lastName: "Garkusha"
 relationship: "friend"
 photo: {
 prefix: "https://irs0.4sqi.net/img/user/"
 suffix: "/FMPLCJSDDBHX0IJM.jpg"
 }
 tips: {
 count: 0
 }
 lists: {
 groups: [
 {
 type: "created"
 count: 1
 items: [ ]
 }
 ]
 }
 gender: "male"
 homeCity: "New York, NY"
 bio: ""
 contact: {
 email: "artem.garkusha@gmail.com"
 facebook: "100000966925313"
 }
 }
 
*/

@end
