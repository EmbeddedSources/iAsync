#import "NSObject+ExpandArray.h"

@implementation NSObject (ExpandArray)

-(id)expandArray
{
   return self;
}

@end

@implementation NSArray (ExpandArray)

-(id)expandArray
{
   NSMutableArray* result_ = [ NSMutableArray array ];
   for ( id object_ in self )
   {
      id newValue_ = [ object_ expandArray ];
      if ( [ newValue_ isKindOfClass: [ NSArray class ] ] )
      {
         [ result_ addObjectsFromArray: newValue_ ];
      }
      else
      {
         [ result_ addObject: newValue_ ];
      }
   }
   return result_;
}

@end

