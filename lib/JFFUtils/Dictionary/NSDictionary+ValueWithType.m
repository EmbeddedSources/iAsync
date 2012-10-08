#import "NSDictionary+ValueWithType.h"

#import "JFFClangLiterals.h"

//TODO test
@implementation NSDictionary (ValueWithType)

- (NSString *)stringForKey:(NSString *)key
{
    id value = self[key];
    
    if (value == nil || [value isKindOfClass:[NSString class]]) {
        return value;
    }
    
    if ([value respondsToSelector:@selector(description)] && ![value isKindOfClass:[NSNull class]]) {
        return [value description];
    }
    
    NSLog(@"!!!WARNING!!! String value for key %@ not found", key);
    
    return nil;
}

- (NSString *)stringForKeyPath:(NSString *)key
{
    id value = [self valueForKeyPath:key];
    
    if (value == nil || [value isKindOfClass:[NSString class]]) {
        return value;
    }
    
    if ([value respondsToSelector:@selector(description)] && ![value isKindOfClass:[NSNull class]] ) {
        return [value description];
    }
    
    NSLog(@"!!!WARNING!!! String value for key %@ not found", key);
    
    return nil;
}

- (NSInteger)integerForKey:(NSString *)key
{
    id value = self[key];

    if (value == nil 
        || [value isKindOfClass:[NSString class]] 
        || [value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }

    NSLog(@"!!!WARNING!!! Integer value for key %@ not found", key);
    return 0;
}

- (BOOL)boolForKey:(NSString *)key
{
    id value = self[key];
    
    if (value == nil 
        || [value isKindOfClass:[NSString class]] 
        || [value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    
    NSLog(@"!!!WARNING!!! Bool value for key %@ not found", key);
    
    return NO;
}

    
- (NSNumber *)numberWithIntegerForKey:(NSString *)key
{
    id value = self[key];
    
    if (value == nil || [value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return @([value integerValue]);
    }
    
    NSLog(@"!!!WARNING!!! Integer value for key %@ not found", key);
    
    return nil;
}

- (NSNumber *)numberWithBoolForKey:(NSString *)key
{
    id value = self[key];
    
    if (value == nil || [value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return @([value boolValue]);
    }
    
    NSLog(@"!!!WARNING!!! Bool value for key %@ not found", key);
    
    return nil;
}
     
#pragma mark - Number with double

- (NSNumber *)numberWithDoubleForKey:(NSString *)key
{
    id value = self[key];
    
    if (value == nil || [value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return @([value doubleValue]);
    }
    
//    NSLog(@"!!!WARNING!!! Double value for key \"%@\" not found", key);
    
    return nil;
}

#pragma mark - Dict vlue for key

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    id value = self[key];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    
//    NSLog(@"!!!WARNING!!! Dictionary for key \"%@\" not found", key);
    
    return nil;
}
     
#pragma mark - Array value for key

- (NSArray *)arrayForKey:(NSString *)key
{
    id value = self[key];
    
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    
    NSLog(@"!!!WARNING!!! Array for key \"%@\" not found", key);
    
    return nil;
}

@end
