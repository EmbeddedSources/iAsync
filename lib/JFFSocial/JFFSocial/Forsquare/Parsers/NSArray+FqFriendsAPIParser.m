#import "NSArray+FqFriendsAPIParser.h"

#import "NSDictionary+FqAPIResponseParser.h"
#import "FoursquareUserModel+APIParser.h"

#import "JFFFoursquaerAPIInvalidResponseError.h"

@implementation NSArray (FqFriendsAPIParser)

+ (NSArray *)fqFriendsWithDict:(NSDictionary *)dictionary error:(NSError **)outError
{
     NSError *error = nil;
    
    NSDictionary *response = [NSDictionary fqApiresponseDictWithDict:dictionary error:&error];
    
    if (error) {
        [error setToPointer:outError];
        return nil;
    }
    
    NSArray *friendsArray = [[response dictionaryForKey:@"friends"] arrayForKey:@"items"];
    
    if (friendsArray) {
        friendsArray = [friendsArray map:^id(NSDictionary *object, NSError *__autoreleasing *outError) {
            
            NSError *error = nil;
            FoursquareUserModel *userModel = [FoursquareUserModel fqUserModelWithDict:object error:&error];
            [error setToPointer:outError];
            return userModel;
            
        } error:&error];
    }
    else
    {
        [[JFFFoursquaerAPIInvalidresponseError new] setToPointer:outError];
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