#import "CXMLElement+Custom.h"

@implementation CXMLElement (Custom)

-(CXMLElement*)firstElementIfExistsForName:( NSString* )name_
                         logMessageEnabled:( BOOL )logMessageEnabled_
                                shouldFail:( BOOL )shouldFail_
{
    NSArray* elements_ = [ self elementsForName: name_ ];
    if ( [ elements_ count ] == 0 )
    {
        if ( logMessageEnabled_ )
        {
            NSLog( @"[!!! WARNING !!!] - No elements for name: %@", name_ );
            NSLog( @"In node : ");
            NSLog( @"%@", self );
        }
        if ( shouldFail_ )
        {
            NSAssert1( NO, @"[!!! ERROR !!!] - No elements for name: %@", name_ );
        }

        return nil;
    }

    return [ elements_ objectAtIndex: 0 ];
}

-(CXMLElement*)firstElementForName:( NSString* )name_
{
    return [ self firstElementIfExistsForName: name_
                            logMessageEnabled: YES
                                   shouldFail: YES ];
    
}

-(CXMLElement*)firstElementForNameNoThrow:( NSString* )name_
{
    return [ self firstElementIfExistsForName: name_
                            logMessageEnabled: YES
                                   shouldFail: NO ];
}

-(CXMLElement*)firstElementIfExistsForName:( NSString* )name_
{
    return [ self firstElementIfExistsForName: name_
                            logMessageEnabled: NO
                                   shouldFail: NO ];
}

@end
