#import <TouchXML/CXMLNode.h>

@interface CXMLNode (Custom)

- (CXMLNode *)firstNodeIfExistsForXPath:(NSString *)xpath
                      namespaceMappings:(NSDictionary *)namespaceMappings;

- (CXMLNode *)firstNodeForXPath:(NSString *)xpath
              namespaceMappings:(NSDictionary *)namespaceMappings;

- (NSArray *)nodesForXPath:(NSString *)xpath
         namespaceMappings:(NSDictionary *)namespaceMappings;

@end
