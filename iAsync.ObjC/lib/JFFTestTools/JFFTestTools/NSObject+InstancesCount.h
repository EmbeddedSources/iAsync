#import <Foundation/Foundation.h>

@interface NSObject (InstancesCount)

+ (void)enableInstancesCounting;

+ (NSUInteger)instancesCount;

@end
