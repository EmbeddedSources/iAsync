#import "NSString+CPlusPlus.h"

@implementation NSString (CPlusPlus)

-(std::string)toStlString
{
    if ( nil == self )
    {
        return "";
    }

    std::string urlCppString_
    ( 
       [ self cStringUsingEncoding: NSUTF8StringEncoding ],
       [ self lengthOfBytesUsingEncoding: NSUTF8StringEncoding ] 
    );

    return urlCppString_;
}

+(id)stringWithStlStringNoCopy:( const std::string& )stlString_
{
    if ( stlString_.empty() )
    {
        return nil;
    }

    char* nonConstCharacters_ = const_cast<char*>( stlString_.c_str() );
    void* castedString_ = reinterpret_cast<void*>( nonConstCharacters_ );

    NSString* result_ = [ [ NSString alloc ] initWithBytesNoCopy: castedString_
                                                          length: stlString_.size()
                                                        encoding: NSUTF8StringEncoding
                                                    freeWhenDone: NO ];

    return result_;
}

@end
