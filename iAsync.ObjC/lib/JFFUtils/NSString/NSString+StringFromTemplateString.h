#import <Foundation/Foundation.h>

@interface NSString (StringFromTemplateString)

- (instancetype)localizedTemplateStringWithVariables:(NSDictionary *)variables;

@end
