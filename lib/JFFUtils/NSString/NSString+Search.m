#import "NSString+Search.h"

@implementation NSString (Search)

-(NSUInteger)numberOfCharacterFromString:( NSString* )string_
{
   NSCharacterSet* set_ = [ NSCharacterSet characterSetWithCharactersInString: string_ ];

   NSUInteger result_ = 0;

   NSRange search_range_ = NSMakeRange( 0, [ self length ] );
   NSRange range_ = [ self rangeOfCharacterFromSet: set_
                                           options: NSLiteralSearch
                                             range: search_range_ ];
   while ( range_.location != NSNotFound )
   {
      ++result_;

      search_range_.location = range_.location + 1;
      search_range_.length = [ self length ] - search_range_.location;
      if ( search_range_.location >= [ self length ] )
         break;

      range_ = [ self rangeOfCharacterFromSet: set_
                                      options: NSLiteralSearch
                                        range: search_range_ ];
   }

   return result_;
}

@end
