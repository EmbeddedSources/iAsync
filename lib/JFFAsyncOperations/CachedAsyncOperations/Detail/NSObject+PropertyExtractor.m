#import "NSObject+PropertyExtractor.h"

#import "JFFPropertyPath.h"

#include <objc/runtime.h>

static char property_data_property_key_;

@interface NSObject (PropertyExtractorPrivate)

@property ( nonatomic ) NSMutableDictionary* propertyDataByPropertyName;

@end

@implementation NSObject (PropertyExtractor)

-(JFFObjectRelatedPropertyData*)propertyDataForPropertPath:( JFFPropertyPath* )propertyPath_
{
    id data_ = self.propertyDataByPropertyName[ propertyPath_.name ];
    if ( propertyPath_.key == nil )
    {
        return data_;
    }
    return [ data_ objectForKey: propertyPath_.key ];
}

-(void)removePropertyForPropertPath:( JFFPropertyPath* )propertyPath_
{
    if ( propertyPath_.key )
    {
        NSMutableDictionary* subDict_ = self.propertyDataByPropertyName[ propertyPath_.name ];
        [ subDict_ removeObjectForKey: propertyPath_.key ];
        if ( [ subDict_ count ] == 0 )
        {
            [ self.propertyDataByPropertyName removeObjectForKey: propertyPath_.name ];
        }
    }
    else
    {
        [ self.propertyDataByPropertyName removeObjectForKey: propertyPath_.name ];
    }

    //clear property
    if ( [ self.propertyDataByPropertyName count ] == 0 )
    {
        self.propertyDataByPropertyName = nil;
    }
}

-(void)setPropertyData:( JFFObjectRelatedPropertyData* )property_
        forPropertPath:( JFFPropertyPath* )propertyPath_
{
    if ( !property_ )
    {
        [ self removePropertyForPropertPath: propertyPath_ ];
        return;
    }

    if ( self.propertyDataByPropertyName == nil )
    {
        self.propertyDataByPropertyName = [ NSMutableDictionary new ];
    }

    if ( propertyPath_.key )
    {
        NSMutableDictionary* subDict_ = [ self.propertyDataByPropertyName objectForKey: propertyPath_.name ];
        if ( subDict_ == nil )
        {
            subDict_ = [ NSMutableDictionary new ];
            self.propertyDataByPropertyName[ propertyPath_.name ] = subDict_;
        }

        subDict_[ propertyPath_.key ] = property_;
        return;
    }

    self.propertyDataByPropertyName[ propertyPath_.name ] = property_;
}

-(NSMutableDictionary*)propertyDataByPropertyName
{
    return objc_getAssociatedObject( self, &property_data_property_key_ );
}

-(void)setPropertyDataByPropertyName:( NSMutableDictionary* )dictionary_
{
    objc_setAssociatedObject( self, &property_data_property_key_, dictionary_, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@end
