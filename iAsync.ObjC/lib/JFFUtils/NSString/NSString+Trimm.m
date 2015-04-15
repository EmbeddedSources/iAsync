#import "NSString+Trimm.h"

@implementation NSString (Trimm)

- (NSRange)rangeForQuotesRemoval
{
    NSString *quotedString = self;
    
    static const NSUInteger firstQuoteOffset = 1;
    static const NSUInteger quotesCount = 2;
    NSUInteger rangeLength = [quotedString length] - quotesCount;
    
    NSRange result = {firstQuoteOffset, rangeLength};
    return result;
}

- (instancetype)stringByTrimmingWhitespaces
{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (instancetype)stringByTrimmingPunctuation
{
    NSCharacterSet *set = [NSCharacterSet punctuationCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (instancetype)stringByTrimmingQuotes
{
    NSRange rangeWithoutQuotes = [self rangeForQuotesRemoval];
    NSString *result = [self substringWithRange:rangeWithoutQuotes];
    
    NSCharacterSet *termWhitespaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    return [result stringByTrimmingCharactersInSet:termWhitespaces];
}

@end
