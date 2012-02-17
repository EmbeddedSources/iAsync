#import <Foundation/Foundation.h>

@class JFFPropertyPath;
@class JFFObjectRelatedPropertyData;

@interface NSObject (PropertyExtractor)

@property ( nonatomic, strong, readonly ) NSMutableDictionary* propertyDataByPropertyName;

-(JFFObjectRelatedPropertyData*)propertyDataForPropertPath:( JFFPropertyPath* )property_path_;
-(void)setPropertyData:( JFFObjectRelatedPropertyData* )property_ forPropertPath:( JFFPropertyPath* )property_path_;

@end
