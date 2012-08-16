#import "NSString+Search.h"

@implementation NSString (Search)

-(NSUInteger)numberofOccurencesWithRangeSearcher:( NSRange(^)( NSRange ) )rangeSearcher_
                                            step:( NSUInteger )step_
{
    NSUInteger result_ = 0;

    NSRange searchRange_ = { 0, [ self length ] };
    NSRange range_ = rangeSearcher_( searchRange_ );

    while ( range_.location != NSNotFound )
    {
        ++result_;

        searchRange_.location = range_.location + step_;
        searchRange_.length   = [ self length ] - searchRange_.location;
        if ( searchRange_.location >= [ self length ] )
            break;

        range_ = rangeSearcher_( searchRange_ );
    }

    return result_;
}

-(NSUInteger)numberOfCharacterFromString:( NSString* )string_
{
    NSCharacterSet* set_ = [ NSCharacterSet characterSetWithCharactersInString: string_ ];

    NSRange (^rangeSearcher_)( NSRange ) = ^NSRange( NSRange rangeToSearch_ )
    {
        return [ self rangeOfCharacterFromSet: set_
                                      options: NSLiteralSearch
                                        range: rangeToSearch_ ];
    };

    return [ self numberofOccurencesWithRangeSearcher: rangeSearcher_
                                                 step: 1 ];
}

-(NSUInteger)numberOfStringsFromString:( NSString* )string_
{
    NSRange (^rangeSearcher_)( NSRange ) = ^NSRange( NSRange rangeToSearch_ )
    {
        return [ self rangeOfString: string_
                            options: NSLiteralSearch
                              range: rangeToSearch_ ];
    };

    return [ self numberofOccurencesWithRangeSearcher: rangeSearcher_
                                                 step: [ string_ length ] ];
}

@end
