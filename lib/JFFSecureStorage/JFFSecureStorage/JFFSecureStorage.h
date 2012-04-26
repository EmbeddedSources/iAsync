#import <Foundation/Foundation.h>

@protocol JFFSecureStorage;

@interface JFFSecureStorage : NSObject

-(void)setPassword:( NSString* )password_
             login:( NSString* )login_
            forURL:( NSURL* )url_;

-(NSString*)passwordAndLogin:( NSString** )login_
                      forURL:( NSURL* )url_;

@end
