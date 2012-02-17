#import <Foundation/Foundation.h>

@interface NSObject (InstancesCount)

//JTODO hook also copy methods
+(void)enableInstancesCounting;

+(NSUInteger)instancesCount;

@end
