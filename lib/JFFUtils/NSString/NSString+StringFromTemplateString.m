#import "NSString+StringFromTemplateString.h"

//source: http://stackoverflow.com/questions/2841553/how-to-create-a-formatted-localized-string

static NSString *specialStringBegin = @"${";
static NSString *specialStringEnd   = @"}";

@implementation NSString (StringFromTemplateString)

- (instancetype)localizedTemplateStringWithVariables:(NSDictionary *)variables
{
    NSMutableString *result = [NSMutableString new];
    // Create scanner with the localized string
    NSString *scannedString = NSLocalizedString(self, nil);
    
    while ([scannedString length] != 0) {
        // Find ${variable} templates
        
        NSRange range = [scannedString rangeOfString:specialStringBegin];
        
        if (range.location != NSNotFound) {
            
            if (range.location > 0) {
                [result appendString:[scannedString substringToIndex:range.location]];
            }
            
            // Skip "@{" syntax
            range.location += 2;
            
            NSRange rangeEnd = [scannedString rangeOfString:specialStringEnd];
            
            if (rangeEnd.location != NSNotFound) {
                
                id variableName = [scannedString substringWithRange:NSMakeRange(range.location, rangeEnd.location - range.location)];
                id variableValue = variables[variableName];
                
                // Check for the variable
                if (variableValue) {
                    if ([variableValue isKindOfClass:[NSString class]]) {
                        // NSString, append
                        [result appendString:variableValue];
                    } else {
                        // Not a NSString, but can handle description, append
                        [result appendString:[NSString localizedStringWithFormat:@"%@", variableValue]];
                    }
                } else {
                    // Not found, localize the template key and append
                    [result appendString:[[NSString alloc] initWithFormat:@"%@%@%@", specialStringBegin, variableName, specialStringEnd]];
                }
                // Skip syntax
                //
                scannedString = [scannedString substringFromIndex:rangeEnd.location + rangeEnd.length];
                continue;
            }
        }
        
        [result appendString:scannedString];
        scannedString = nil;
    }
    
    return result;
}

@end
