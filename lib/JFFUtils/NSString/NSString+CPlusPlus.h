#import <Foundation/Foundation.h>
#include <string>

@interface NSString (CPlusPlus)

-(std::string)toStlString;
+(id)stringWithStlStringNoCopy:( const std::string& )stlString_;

@end
