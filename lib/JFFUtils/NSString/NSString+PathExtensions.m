#import "NSString+PathExtensions.h"

@implementation NSString ( PathExtensions )

+(NSString*)pathWithDirectory:( NSSearchPathDirectory )directory_
       appendingPathComponent:( NSString* )str_
{
    NSArray* pathes_ = NSSearchPathForDirectoriesInDomains( directory_, NSUserDomainMask, YES );
    NSString* documentDirectory_ = [ pathes_ lastObject ];
    return [ documentDirectory_ stringByAppendingPathComponent: str_ ];
}

+(NSString*)documentsPathByAppendingPathComponent:( NSString* )str_
{
    return [ self pathWithDirectory: NSDocumentDirectory
             appendingPathComponent: str_ ];
}

+(NSString*)cachesPathByAppendingPathComponent:( NSString* )str_
{
    return [ self pathWithDirectory: NSCachesDirectory
             appendingPathComponent: str_ ];
}

@end
