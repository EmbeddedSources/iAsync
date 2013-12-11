#import "NSError+JSON.h"

@implementation NSError (JSON)

-(NSString*)toJson
{
    NSString* strCode = [ @( self.code ) descriptionWithLocale: nil ];
    
    return [ NSString stringWithFormat: @"{ \"error\" : \"%@\", \"domain\" : \"%@\", \"code\" : \"%@\", \"localizedDescription\" : \"%@\" }", NSStringFromClass( [ self class ] ), self.domain, strCode, self.localizedDescription ];
}

@end
