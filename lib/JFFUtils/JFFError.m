#import "JFFError.h"

@implementation JFFError

-(id)initWithDescription:( NSString* )description_
                  domain:( NSString* )domain_
                    code:( NSInteger )code_
{
   NSDictionary* user_info_ = [ NSDictionary dictionaryWithObject: description_ forKey: NSLocalizedDescriptionKey ];
   return [ super initWithDomain: domain_
                            code: code_
                        userInfo: user_info_ ];
}

-(id)initWithDescription:( NSString* )description_ code:( NSInteger )code_
{
   return [ self initWithDescription: description_
                              domain: @"com.just_for_fun.library"
                                code: code_ ];
}

-(id)initWithDescription:( NSString* )description_
{
   return [ self initWithDescription: description_ code: 0 ];
}

+(id)errorWithDescription:( NSString* )description_ code:( NSInteger )code_
{
   return [ [ self alloc ] initWithDescription: description_ code: code_ ];
}

+(id)errorWithDescription:( NSString* )description_
{
   return [ [ self alloc ] initWithDescription: description_ ];
}

@end
