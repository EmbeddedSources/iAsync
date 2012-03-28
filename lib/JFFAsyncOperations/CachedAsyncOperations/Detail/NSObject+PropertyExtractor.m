#import "NSObject+PropertyExtractor.h"

#import "JFFPropertyPath.h"

#include <objc/runtime.h>

static char property_data_property_key_;

@interface NSObject (PropertyExtractorPrivate)

@property ( nonatomic, strong ) NSMutableDictionary* propertyDataByPropertyName;

@end

@implementation NSObject (PropertyExtractor)

-(JFFObjectRelatedPropertyData*)propertyDataForPropertPath:( JFFPropertyPath* )property_path_
{
   id data_ = [ self.propertyDataByPropertyName objectForKey: property_path_.name ];
   if ( property_path_.key == nil )
   {
      return data_;
   }
   return [ data_ objectForKey: property_path_.key ];
}

-(void)removePropertyForPropertPath:( JFFPropertyPath* )property_path_
{
   if ( property_path_.key )
   {
      NSMutableDictionary* sub_dict_ = [ self.propertyDataByPropertyName objectForKey: property_path_.name ];
      [ sub_dict_ removeObjectForKey: property_path_.key ];
      if ( [ sub_dict_ count ] == 0 )
      {
         [ self.propertyDataByPropertyName removeObjectForKey: property_path_.name ];
      }
   }
   else
   {
      [ self.propertyDataByPropertyName removeObjectForKey: property_path_.name ];
   }

   //clear property
   if ( [ self.propertyDataByPropertyName count ] == 0 )
   {
      self.propertyDataByPropertyName = nil;
   }
}

-(void)setPropertyData:( JFFObjectRelatedPropertyData* )property_
        forPropertPath:( JFFPropertyPath* )property_path_
{
    if ( !property_ )
    {
        [ self removePropertyForPropertPath: property_path_ ];
        return;
    }

    if ( self.propertyDataByPropertyName == nil )
    {
        self.propertyDataByPropertyName = [ NSMutableDictionary new ];
    }

    if ( property_path_.key )
    {
        NSMutableDictionary* sub_dict_ = [ self.propertyDataByPropertyName objectForKey: property_path_.name ];
        if ( sub_dict_ == nil )
        {
            sub_dict_ = [ NSMutableDictionary new ];
            [ self.propertyDataByPropertyName setObject: sub_dict_ forKey: property_path_.name ];
        }

        [ sub_dict_ setObject: property_ forKey: property_path_.key ];
        return;
    }

    [ self.propertyDataByPropertyName setObject: property_ forKey: property_path_.name ];
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
