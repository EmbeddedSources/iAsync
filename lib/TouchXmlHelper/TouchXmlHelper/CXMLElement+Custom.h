#import <TouchXML/CXMLElement.h>

@interface CXMLElement (Custom)

-(CXMLElement*)firstElementForName:( NSString* )name_;

-(CXMLElement*)firstElementForNameNoThrow:( NSString* )name_;
-(CXMLElement*)firstElementIfExistsForName:( NSString* )name_;

@end
