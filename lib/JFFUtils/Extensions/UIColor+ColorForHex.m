#import "UIColor+ColorForHex.h"

#import "NSString+Trimm.h"

//source: http://iphonedevelopertips.com/general/using-nsscanner-to-convert-hex-to-rgb-color.html
@implementation UIColor (ColorForHex)

+(UIColor*)colorForHex:( NSString* )hexColor_
{
	hexColor_ = [ [ hexColor_ stringByTrimmingWhitespaces ] uppercaseString ];

    // String should be 6 or 7 characters if it includes '#'
    if ( [ hexColor_ length ] < 6 )
		return [ UIColor blackColor ];

    // strip # if it appears
    if ( [ hexColor_ hasPrefix: @"#" ] )
		hexColor_ = [ hexColor_ substringFromIndex: 1 ];

    // if the value isn't 6 characters at this point return
    // the color black
    if ( [ hexColor_ length ] != 6 )
		return [ UIColor blackColor ];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length   = 2;

    NSString *rString = [ hexColor_ substringWithRange: range ];

    range.location = 2;
    NSString *gString = [ hexColor_ substringWithRange: range ];

    range.location = 4;
    NSString *bString = [ hexColor_ substringWithRange: range ];

    // Scan values  
    unsigned int r, g, b;  
    [ [ NSScanner scannerWithString: rString ] scanHexInt:&r];
    [ [ NSScanner scannerWithString: gString ] scanHexInt:&g];
    [ [ NSScanner scannerWithString: bString ] scanHexInt:&b];

    return [ self colorWithRed: ((float) r / 255.0f)
                         green: ((float) g / 255.0f)
                          blue: ((float) b / 255.0f)
                         alpha: 1.0f ];
}

@end
