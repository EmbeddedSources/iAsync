#import "NSMutableArray+AddNonEmptyObject.h"

@implementation NSMutableArray (AddNonEmptyObject)

-(void)addNonEmptyString:( NSString* )string_
{
    if ( [ string_ length ] != 0 )
        [ self addObject: string_ ];
}

@end
