#import "NSString+Trimm.h"

@implementation NSString (Trimm)

-(NSRange)rangeForQuotesRemoval
{
    NSString* quoted_string_ = self;

    static const NSUInteger first_quote_offset_ = 1;
    static const NSUInteger quotes_count_ = 2;
    NSUInteger range_length_ = [ quoted_string_ length ] - quotes_count_;

    NSRange result_ = NSMakeRange( first_quote_offset_, range_length_ );
    return result_;
}

-(NSString*)stringByTrimmingWhitespaces
{
    return [ self stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ] ];
}

-(NSString*)stringByTrimmingPunctuation
{
    return [ self stringByTrimmingCharactersInSet: [ NSCharacterSet punctuationCharacterSet ] ];
}

-(NSString*)stringByTrimmingQuotes
{
    NSRange range_without_quotes_ = [ self rangeForQuotesRemoval ];
    NSString* result_ = [ self substringWithRange: range_without_quotes_ ];
   
    NSCharacterSet* term_whitespaces_ = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
   
    return [ result_ stringByTrimmingCharactersInSet: term_whitespaces_ ];
}

@end
