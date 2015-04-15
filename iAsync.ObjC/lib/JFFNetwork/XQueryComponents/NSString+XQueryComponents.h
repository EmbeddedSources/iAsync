#import <Foundation/Foundation.h>

@interface NSString (XQueryComponents)

- (instancetype)stringByDecodingURLFormat;
- (instancetype)stringByEncodingURLFormat;
- (NSDictionary *)dictionaryFromQueryComponents;

@end
