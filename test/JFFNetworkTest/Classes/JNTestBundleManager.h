#import <Foundation/Foundation.h>

@interface JNTestBundleManager : NSObject

+(NSBundle*)decodersDataBundle;
+(NSData*)loadZipFileNamed:( NSString* )file_name_;
+(NSString*)loadTextFileNamed:( NSString* )file_name_;

@end
