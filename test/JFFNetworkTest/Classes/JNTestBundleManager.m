#import "JNTestBundleManager.h"

@implementation JNTestBundleManager

+(NSBundle*)decodersDataBundle
{
    NSBundle* main_bundle_ = [ NSBundle bundleForClass: [ self class ] ];

    NSString* result_path_ = [ main_bundle_ pathForResource: @"JFFNetworkTestData"
                                                     ofType: @"bundle" ];

    return [ NSBundle bundleWithPath: result_path_ ];
}

+(NSData*)loadZipFileNamed:( NSString* )file_name_
{
    NSString* result_path_ = [ [ self decodersDataBundle ] pathForResource: file_name_
                                                                    ofType: @"zip" ];

    return [ NSData dataWithContentsOfFile: result_path_ ];
}

+(NSString*)loadTextFileNamed:( NSString* )file_name_
{
    NSString* result_path_ = [ [ self decodersDataBundle ] pathForResource: file_name_
                                                                   ofType: @"txt" ];

    NSError* error_ = nil;

    NSString* result_ = [ NSString stringWithContentsOfFile: result_path_
                                                   encoding: NSUTF8StringEncoding
                                                      error: &error_ ];
    if ( nil != error_ )
    {
        NSLog( @"[!!! ERROR !!!] : wrong resource type at '%@' ", result_path_ );
    }

    return result_;
}

@end
