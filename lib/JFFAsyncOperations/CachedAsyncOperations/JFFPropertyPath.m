#import "JFFPropertyPath.h"

@implementation JFFPropertyPath

@synthesize name = _name;
@synthesize key = _key;

-(id)initWithName:( NSString* )name_
              key:( id< NSCopying, NSObject > )key_
{
    self = [ super init ];

    if ( self )
    {
        _name = name_;
        _key  = key_;
    }

    return self;
}

-(NSString*)description
{
    return [ NSString stringWithFormat: @"<JFFPropertyPath name: %@ key: %@>", self.name, self.key ];
}

@end
