#import "NSString+Search.h"

@implementation NSString (Search)

-(NSUInteger)numberOfCharacterFromString:( NSString* )string_
{
    NSCharacterSet* set_ = [ NSCharacterSet characterSetWithCharactersInString: string_ ];

    NSUInteger result_ = 0;

    NSRange searchRange_ = NSMakeRange( 0, [ self length ] );
    NSRange range_ = [ self rangeOfCharacterFromSet: set_
                                            options: NSLiteralSearch
                                              range: searchRange_ ];
    while ( range_.location != NSNotFound )
    {
        ++result_;

        searchRange_.location = range_.location + 1;
        searchRange_.length = [ self length ] - searchRange_.location;
        if ( searchRange_.location >= [ self length ] )
            break;

        range_ = [ self rangeOfCharacterFromSet: set_
                                        options: NSLiteralSearch
                                          range: searchRange_ ];
    }

    return result_;
}

@end
