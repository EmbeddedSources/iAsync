#import "NSString+CPlusPlus.h"

@implementation NSString (CPlusPlus)

- (std::string)toStlString
{
    if (nil == self) {
        return "";
    }
    
    std::string urlCppString
    ( 
       [self cStringUsingEncoding:NSUTF8StringEncoding],
       [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]
    );
    
    return urlCppString;
}

+ (instancetype)stringWithStlStringNoCopy:(const std::string&)stlString
{
    if (stlString.empty()) {
        return nil;
    }
    
    char *nonConstCharacters = const_cast<char *>(stlString.c_str());
    void *castedString = reinterpret_cast<void *>(nonConstCharacters);
    
    NSString *result = [[NSString alloc] initWithBytesNoCopy:castedString
                                                      length:stlString.size()
                                                    encoding:NSUTF8StringEncoding
                                                freeWhenDone:NO];
    
    return result;
}

@end
