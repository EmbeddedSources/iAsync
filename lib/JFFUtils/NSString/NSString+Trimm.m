#import "NSString+Trimm.h"

@implementation NSString (Trimm)

-(NSRange)rangeForQuotesRemoval
{
    NSString* quotedString_ = self;

    static const NSUInteger firstQuoteOffset_ = 1;
    static const NSUInteger quotesCount_ = 2;
    NSUInteger rangeLength_ = [ quotedString_ length ] - quotesCount_;

    NSRange result_ = { firstQuoteOffset_, rangeLength_ };
    return result_;
}

-(NSString*)stringByTrimmingWhitespaces
{
    NSCharacterSet* set_ = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
    return [ self stringByTrimmingCharactersInSet: set_ ];
}

-(NSString*)stringByTrimmingPunctuation
{
    NSCharacterSet* set_ = [ NSCharacterSet punctuationCharacterSet ];
    return [ self stringByTrimmingCharactersInSet: set_ ];
}

-(NSString*)stringByTrimmingQuotes
{
    NSRange rangeWithoutQuotes_ = [ self rangeForQuotesRemoval ];
    NSString* result_ = [ self substringWithRange: rangeWithoutQuotes_ ];

    NSCharacterSet* termWhitespaces_ = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];

    return [ result_ stringByTrimmingCharactersInSet: termWhitespaces_ ];
}

@end
