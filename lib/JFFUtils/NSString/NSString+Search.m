#import "NSString+Search.h"

@implementation NSString (Search)

- (NSUInteger)numberofOccurencesWithRangeSearcher:(NSRange(^)(NSRange))rangeSearcher
                                             step:(NSUInteger)step
{
    NSUInteger result = 0;
    
    NSRange searchRange = {0, [self length]};
    NSRange range = rangeSearcher(searchRange);
    
    while (range.location != NSNotFound)
    {
        ++result;
        
        searchRange.location = range.location + step;
        searchRange.length   = [ self length ] - searchRange.location;
        if (searchRange.location >= [self length])
            break;
        
        range = rangeSearcher(searchRange);
    }
    
    return result;
}

- (NSUInteger)numberOfCharacterFromString:(NSString *)string
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString: string];
    
    NSRange (^rangeSearcher)(NSRange) = ^NSRange(NSRange rangeToSearch)
    {
        return [self rangeOfCharacterFromSet: set
                                     options: NSLiteralSearch
                                       range: rangeToSearch];
    };
    
    return [self numberofOccurencesWithRangeSearcher: rangeSearcher
                                                step: 1];
}

- (NSUInteger)numberOfStringsFromString:(NSString *)string
{
    NSRange (^rangeSearcher)(NSRange) = ^NSRange(NSRange rangeToSearch)
    {
        return [self rangeOfString: string
                           options: NSLiteralSearch
                             range: rangeToSearch];
    };
    
    return [self numberofOccurencesWithRangeSearcher: rangeSearcher
                                                step: [string length]];
}

- (BOOL)containsString:(NSString *)string
{
    NSRange range = [self rangeOfString: string
                                options: NSLiteralSearch
                                  range: (NSRange){0, [self length]}];
    
    return range.location != NSNotFound;
}

- (BOOL)caseInsensitiveContainsString:(NSString *)string
{
    NSRange range = [ self rangeOfString: string
                                 options: NSCaseInsensitiveSearch
                                   range: (NSRange){0, [self length]}];
    
    return range.location != NSNotFound;
}

@end
