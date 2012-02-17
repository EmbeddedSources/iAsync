#import "NSString+PathExtensions.h"

@implementation NSString ( PathExtensions )

+(NSString*)documentsPathByAppendingPathComponent:( NSString* )str_
{
   NSString* document_directory_ = [ NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) lastObject ];
   return [ document_directory_ stringByAppendingPathComponent: str_ ];
}

@end
