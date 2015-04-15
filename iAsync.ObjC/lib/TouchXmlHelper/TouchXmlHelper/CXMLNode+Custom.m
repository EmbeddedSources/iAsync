#import "CXMLNode+Custom.h"

@implementation CXMLNode (Custom)

- (CXMLNode *)firstNodeIfExistsForXPath:(NSString *)xpath
                      namespaceMappings:(NSDictionary *)namespaceMappings
                      logMessageEnabled:(BOOL)logMessageEnabled
                             shouldFail:(BOOL)shouldFail
{
    NSArray *nodes = [self nodesForXPath:xpath namespaceMappings:namespaceMappings];
    if ([nodes count] == 0) {
        
        if (logMessageEnabled) {
            NSLog(@"[!!! WARNING !!!] - No elements for path: %@", xpath);
            NSLog(@"In node : ");
            NSLog(@"%@", self );
        }
        if (shouldFail) {
            NSAssert1(NO, @"[!!! ERROR !!!] - No elements for path: %@", xpath);
        }
        
        return nil;
    }
    
    return nodes[0];
}

- (CXMLNode *)firstNodeIfExistsForXPath:(NSString *)xpath
                      namespaceMappings:(NSDictionary *)namespaceMappings
{
    return [self firstNodeIfExistsForXPath:xpath
                         namespaceMappings:namespaceMappings
                         logMessageEnabled:NO
                                shouldFail:NO];
}

- (CXMLNode *)firstNodeForXPath:(NSString *)xpath
              namespaceMappings:(NSDictionary *)namespaceMappings
{
    return [self firstNodeIfExistsForXPath:xpath
                         namespaceMappings:namespaceMappings
                         logMessageEnabled:YES
                                shouldFail:YES];
}

- (NSArray *)nodesForXPath:(NSString *)xpath
         namespaceMappings:(NSDictionary *)namespaceMappings
{
    return [self nodesForXPath:xpath namespaceMappings:namespaceMappings error:0];
}

@end
