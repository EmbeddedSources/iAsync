#import <Foundation/Foundation.h>

@interface NSUrlLocationValidator : NSObject

+(BOOL)isValidLocation:( NSString* )location_;
+(BOOL)isLocationValidURL:( NSString* )location_;

@end
