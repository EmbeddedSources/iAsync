#import <Foundation/Foundation.h>

@class JFFPropertyPath;
@class JFFObjectRelatedPropertyData;

@interface NSObject (PropertyExtractor)

@property (nonatomic, readonly) NSMutableDictionary *propertyDataByPropertyName;

- (JFFObjectRelatedPropertyData *)propertyDataForPropertPath:(JFFPropertyPath *)propertyPath;
- (void)setPropertyData:(JFFObjectRelatedPropertyData *)property forPropertPath:(JFFPropertyPath *)propertyPath;

@end
