#import <Foundation/Foundation.h>

@interface NSString (Search)

-(NSUInteger)numberOfCharacterFromString:( NSString* )string_;
-(NSUInteger)numberOfStringsFromString:( NSString* )string_;

-(BOOL)containsString:( NSString* )string_;
-(BOOL)caseInsensitiveContainsString:( NSString* )string_;

@end
