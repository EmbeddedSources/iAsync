#import "CXMLNode+Custom.h"


@implementation CXMLNode (Custom)

-(CXMLNode*)firstNodeIfExistsForXPath:( NSString* )xpath_
                    namespaceMappings:( NSDictionary* )namespaceMappings_
                    logMessageEnabled:( BOOL )logMessageEnabled_
                           shouldFail:( BOOL )shouldFail_
{
    NSArray* nodes_ = [ self nodesForXPath: xpath_ namespaceMappings: namespaceMappings_ ];
    if ( [ nodes_ count ] == 0 )
    {
        if ( logMessageEnabled_ )
        {
            NSLog( @"[!!! WARNING !!!] - No elements for path: %@", xpath_ );
            NSLog( @"In node : ");
            NSLog( @"%@", self );
        }
        if ( shouldFail_ )
        {
            NSAssert1( NO, @"[!!! ERROR !!!] - No elements for path: %@", xpath_ );
        }

        return nil;
    }

    return [ nodes_ objectAtIndex: 0 ];
}

-(CXMLNode*)firstNodeIfExistsForXPath:( NSString* )xpath_
                    namespaceMappings:( NSDictionary* )namespaceMappings_
{
    return [ self firstNodeIfExistsForXPath: xpath_
                          namespaceMappings: namespaceMappings_
                          logMessageEnabled: NO
                                 shouldFail: NO ];
}

-(CXMLNode*)firstNodeForXPath:( NSString* )xpath_
            namespaceMappings:( NSDictionary* )namespaceMappings_
{
    return [ self firstNodeIfExistsForXPath: xpath_
                          namespaceMappings: namespaceMappings_
                          logMessageEnabled: YES
                                 shouldFail: YES ];
}

-(NSArray*)nodesForXPath:( NSString* )xpath_
       namespaceMappings:( NSDictionary* )namespace_mappings_
{
    return [ self nodesForXPath: xpath_ namespaceMappings: namespace_mappings_ error: 0 ];
}

@end
