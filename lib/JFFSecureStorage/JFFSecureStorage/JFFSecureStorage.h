#import <Foundation/Foundation.h>

// TODO : Rewrite in C++. This can be easily reversed by tools like class_dump_z
// http://code.google.com/p/networkpx/wiki/class_dump_z

//TODO : Use own custom encryption as the one from Apple is exploited

@protocol JFFSecureStorage;

@interface JFFSecureStorage : NSObject

-(void)setPassword:( NSString* )password_
             login:( NSString* )login_
            forURL:( NSURL* )url_;

-(NSString*)passwordAndLogin:( NSString** )login_
                      forURL:( NSURL* )url_;

@end
