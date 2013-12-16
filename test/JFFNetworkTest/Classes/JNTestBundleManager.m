#import "JNTestBundleManager.h"

@implementation JNTestBundleManager

+ (NSBundle *)decodersDataBundle
{
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    
    NSString* resultPath = [mainBundle pathForResource:@"JFFNetworkTestData"
                                                ofType:@"bundle"];
    
    return [NSBundle bundleWithPath:resultPath];
}

+ (NSData *)loadZipFileNamed:(NSString *)fileName
{
    NSString *resultPath = [[self decodersDataBundle] pathForResource:fileName
                                                               ofType:@"zip"];
    
    return [NSData dataWithContentsOfFile:resultPath];
}

+ (NSString *)loadTextFileNamed:(NSString *)fileName
{
    NSString *resultPath = [[self decodersDataBundle] pathForResource:fileName
                                                               ofType:@"txt"];
    
    NSError *error = nil;
    
    NSString *result = [NSString stringWithContentsOfFile:resultPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    if (nil != error) {
        
        NSLog(@"[!!! ERROR !!!] : wrong resource type at '%@' ", resultPath);
    }
    
    return result;
}

@end
