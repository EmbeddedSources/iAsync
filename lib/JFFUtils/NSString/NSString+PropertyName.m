#import "NSString+PropertyName.h"

static NSString *const setterPreffix = @"set";
static NSString *const setterSuffix  = @":";

@implementation NSString (PropertyName)

- (instancetype)propertyGetNameFromPropertyName
{
    NSUInteger stringLength = [self length];
    if (stringLength <= 4
        || ![self hasSuffix:setterSuffix]
        || ![self hasPrefix:setterPreffix])
        return nil;
    
    NSRange range1 = {3, 1};
    NSString *namePart1 = [self substringWithRange:range1];
    NSRange range2 = {4, stringLength - 5};
    NSString *namePart2 = [self substringWithRange:range2];
    
    return [[namePart1 lowercaseString] stringByAppendingString:namePart2];
}

- (instancetype)propertySetNameForPropertyName
{
    if ([self hasSuffix:setterSuffix])
        return nil;
    
    NSUInteger stringLength = [self length];
    NSRange range1 = {0, 1};
    NSString *propertyNamePart1 = [[self substringWithRange:range1]capitalizedString];
    NSRange range2 = {1, stringLength - 1};
    NSString *propertyNamePart2= [self substringWithRange:range2];
    NSString *result = [propertyNamePart1 stringByAppendingString:propertyNamePart2];
    
    return [[setterPreffix stringByAppendingString:result]stringByAppendingString:setterSuffix];
}

@end
