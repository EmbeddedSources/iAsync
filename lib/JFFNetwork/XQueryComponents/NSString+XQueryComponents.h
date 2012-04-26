#import <Foundation/Foundation.h>

@interface NSString (XQueryComponents)

-(NSString*)stringByDecodingURLFormat;
-(NSString*)stringByEncodingURLFormat;
-(NSDictionary*)dictionaryFromQueryComponents;

@end
