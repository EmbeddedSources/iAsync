#import <Foundation/Foundation.h>

@interface NSString ( PathExtensions )

+(NSString*)documentsPathByAppendingPathComponent:( NSString* )str_;

+(NSString*)cachesPathByAppendingPathComponent:( NSString* )str_;

@end
