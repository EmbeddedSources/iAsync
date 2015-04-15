#import <Foundation/Foundation.h>

@interface FoursquareUserModel : NSObject

@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *photoURL;

@property (nonatomic) NSDictionary *contacts;

@end
