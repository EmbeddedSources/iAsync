#import "NSArray+FqFriendsAPIParser.h"

#import "FoursquareUserModel+APIParser.h"

#import "JFFFoursquaerAPIInvalidResponseError.h"

@implementation NSArray (FqFriendsAPIParser)

+ (NSArray *)fqFriendsWithDict:(NSDictionary *)response error:(NSError **)outError
{
    NSArray *friendsArray = [response[@"friends"] arrayForKey:@"items"];
    
    if (friendsArray) {
        friendsArray = [friendsArray map:^id(NSDictionary *object, NSError *__autoreleasing *outError) {
            
            FoursquareUserModel *userModel = [FoursquareUserModel fqUserModelWithDict:object error:outError];
            return userModel;
            
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

@end

/*
 {
 meta: {
 code: 200
 }
 notifications: [
 {
 type: "notificationTray"
 item: {
 unreadCount: 0
 }
 }
 ]
 response: {
 friends: {
 count: 2
 items: [
 ...
 ]
 }
 gender: "male"
 homeCity: "Dnipropetrovsk"
 bio: ""
 contact: {
 email: "usstass1@gmail.com"
 facebook: "100001816197935"
 }
 }
 ]
 }
 }
 }
 
*/