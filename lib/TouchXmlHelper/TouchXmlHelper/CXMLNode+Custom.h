#import <TouchXML/CXMLNode.h>

@interface CXMLNode (Custom)

-(CXMLNode*)firstNodeIfExistsForXPath:( NSString* )xpath_
                    namespaceMappings:( NSDictionary* )namespaceMappings_;

-(CXMLNode*)firstNodeForXPath:( NSString* )xpath_
            namespaceMappings:( NSDictionary* )namespaceMappings_;

-(NSArray*)nodesForXPath:( NSString* )xpath_
       namespaceMappings:( NSDictionary* )namespaceMappings_;

@end
