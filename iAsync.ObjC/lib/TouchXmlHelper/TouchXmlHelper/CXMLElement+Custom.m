#import "CXMLElement+Custom.h"

@implementation CXMLElement (Custom)

- (CXMLElement *)firstElementIfExistsForName:(NSString *)name
                           logMessageEnabled:(BOOL)logMessageEnabled
                                  shouldFail:(BOOL)shouldFail
{
    NSArray *elements = [self elementsForName:name];
    if ([elements count] == 0) {
        
        if (logMessageEnabled) {
            
            NSLog(@"[!!! WARNING !!!] - No elements for name: %@", name);
            NSLog(@"In node : ");
            NSLog(@"%@", self);
        }
        if (shouldFail) {
            NSAssert1(NO, @"[!!! ERROR !!!] - No elements for name: %@", name);
        }
        
        return nil;
    }
    
    return elements[0];
}

- (CXMLElement *)firstElementForName:(NSString *)name
{
    return [self firstElementIfExistsForName:name
                           logMessageEnabled:YES
                                  shouldFail:YES];
    
}

- (CXMLElement *)firstElementForNameNoThrow:(NSString *)name
{
    return [self firstElementIfExistsForName:name
                           logMessageEnabled:YES
                                  shouldFail:NO];
}

- (CXMLElement *)firstElementIfExistsForName:(NSString *)name
{
    return [self firstElementIfExistsForName:name
                           logMessageEnabled:NO
                                  shouldFail:NO];
}

@end
