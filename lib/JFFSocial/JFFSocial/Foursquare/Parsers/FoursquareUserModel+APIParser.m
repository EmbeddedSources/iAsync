#import "FoursquareUserModel+APIParser.h"

@implementation FoursquareUserModel (APIParser)

+ (instancetype)fqUserModelWithDict:(NSDictionary *)dict error:(NSError **)outError
{
//TODO use validator
//    id jsonPattern = @{
//    @"id"           : [NSString class],
//    @"firstName"    : [NSString class],
//    @"lastName"     : [NSString class],
//    @"contact"      : [NSDictionary class],
//    @"photo.prefix" : [NSString class],
//    @"photo.suffix" : [NSString class],
//    };
//    
//    if( ![JFFJsonObjectValidator validateJsonObject:jsonObject
//                                    withJsonPattern:jsonPattern
//                                              error:outError])
//    {
//        return nil;
//    }
    
    FoursquareUserModel *model = [self new];
    
    model.userID    = dict[@"id"];
    model.firstName = dict[@"firstName"];
    model.lastName  = dict[@"lastName"];
    model.contacts  = [dict dictionaryForKey:@"contact"];
    model.photoURL  = [[dict stringForKeyPath:@"photo.prefix"] stringByAppendingString:[dict stringForKeyPath:@"photo.suffix"]];
    
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
