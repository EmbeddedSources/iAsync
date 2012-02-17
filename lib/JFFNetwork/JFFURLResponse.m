#import "JFFURLResponse.h"

#import "JFFUrlResponseLogger.h"

@implementation JFFURLResponse

@synthesize statusCode = _status_code;
@synthesize allHeaderFields = _all_header_fields;

@dynamic expectedContentLength;

-(void)dealloc
{
   [ _all_header_fields release ];

   [ super dealloc ];
}

-(long long)expectedContentLength
{
   return [ [ _all_header_fields objectForKey: @"Content-Length" ] longLongValue ];
}

#pragma mark -
#pragma mark NSObject
-(NSString*)description
{
   NSString* custom_ = [ JFFUrlResponseLogger descriptionStringForUrlResponse: self ];
   return [ NSString stringWithFormat: @"%@ \n   %@", [ super description ], custom_ ];
}

@end
