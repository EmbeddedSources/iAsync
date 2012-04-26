#import <Foundation/Foundation.h>

@interface NSDictionary (XQueryComponents)

-(NSString*)stringFromQueryComponents;
-(NSString*)firstValueIfExsistsForKey:( NSString* )key_;

@end
