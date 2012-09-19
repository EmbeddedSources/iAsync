#import <TouchXML/CXMLElement.h>

@interface CXMLElement (Custom)

- (CXMLElement *)firstElementForName:(NSString *)name;

- (CXMLElement *)firstElementForNameNoThrow:(NSString *)name;
- (CXMLElement *)firstElementIfExistsForName:(NSString *)name;

@end
