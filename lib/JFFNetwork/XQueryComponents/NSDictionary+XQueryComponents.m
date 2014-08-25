#import "NSDictionary+XQueryComponents.h"

#import "NSString+XQueryComponents.h"

static NSString *const queryComponentFormat    = @"%@=%@";
static NSString *const queryComponentSeparator = @"&";

@interface NSObject (XQueryComponents)

- (NSArray *)arrayOfQueryComponentsForKey:(NSString *)key;
- (NSString *)stringFromQueryComponentAndKey:(NSString *)key;

@end

@implementation NSObject (XQueryComponents)

- (NSString *)stringFromQueryComponentAndKey:(NSString *)key
{
    return [[self description] stringFromQueryComponentAndKey:key];
}

- (NSArray *)arrayOfQueryComponentsForKey:(NSString *)key
{
    NSString *component = [self stringFromQueryComponentAndKey:key];
    return @[component];
}

@end

@implementation NSString (XQueryComponents_Private)

- (NSString *)stringFromQueryComponentAndKey:(NSString *)key
{
    NSString *value = [[self description] stringByEncodingURLFormat];
    return [[NSString alloc] initWithFormat:queryComponentFormat, key, value];
}

@end

@implementation NSArray (XQueryComponents)

- (instancetype)arrayOfQueryComponentsForKey:(NSString *)key
{
    if (self.count == 0) {
        return @[[@"" stringFromQueryComponentAndKey:key]];
    }
    
    return [self map:^id(id value) {
        return [value stringFromQueryComponentAndKey:key];
    }];
}

@end

@implementation NSDictionary (XQueryComponents)

- (NSString *)stringFromQueryComponents
{
    NSArray *result = [[self allKeys] flatten:^NSArray*(id key) {
        NSObject *values = self[key];
        NSString *encodedKey = [key stringByEncodingURLFormat];
        return [values arrayOfQueryComponentsForKey:encodedKey];
    }];
    return [result componentsJoinedByString:queryComponentSeparator];
}

- (NSData *)dataFromQueryComponents
{
    return [[self stringFromQueryComponents] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)firstValueIfExsistsForKey:(NSString *)key
{
    return [self[key] firstObject];
}

@end
