#import "JNTestBundleManager.h"

@implementation JNTestBundleManager

+ (NSBundle *)decodersDataBundle
{
    NSBundle* main_bundle_ = [ NSBundle bundleForClass: [ self class ] ];

    NSString* result_path_ = [ main_bundle_ pathForResource: @"JFFNetworkTestData"
                                                     ofType: @"bundle" ];

    return [ NSBundle bundleWithPath: result_path_ ];
}

+ (NSData *)loadZipFileNamed:(NSString *)file_name_
{
    NSString* result_path_ = [ [ self decodersDataBundle ] pathForResource: file_name_
                                                                    ofType: @"zip" ];

    return [ NSData dataWithContentsOfFile: result_path_ ];
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
