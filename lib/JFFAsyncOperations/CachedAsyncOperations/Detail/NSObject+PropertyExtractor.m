#import "NSObject+PropertyExtractor.h"

#import "JFFPropertyPath.h"

@interface NSObject (PropertyExtractorPrivate)

@property (nonatomic) NSMutableDictionary *propertyDataByPropertyName;

@end

@implementation NSObject (PropertyExtractor)

@dynamic propertyDataByPropertyName;

+ (void)load
{
    jClass_implementProperty(self, @"propertyDataByPropertyName");
}

- (JFFObjectRelatedPropertyData *)propertyDataForPropertPath:(JFFPropertyPath *)propertyPath
{
    id data = self.propertyDataByPropertyName[propertyPath.name];
    if (propertyPath.key == nil) {
        return data;
    }
    return [data objectForKey:propertyPath.key];
}

//JTODO test
- (void)removePropertyForPropertPath:(JFFPropertyPath *)propertyPath
{
    if (propertyPath.key) {
        NSMutableDictionary *subDict = self.propertyDataByPropertyName[propertyPath.name];
        [subDict removeObjectForKey:propertyPath.key];
        if ([subDict count] == 0) {
            [self.propertyDataByPropertyName removeObjectForKey:propertyPath.name];
        }
    } else {
        [self.propertyDataByPropertyName removeObjectForKey:propertyPath.name];
    }
    
    //clear property
    if ([self.propertyDataByPropertyName count] == 0) {
        self.propertyDataByPropertyName = nil;
    }
}

- (void)setPropertyData:(JFFObjectRelatedPropertyData *)property
         forPropertPath:(JFFPropertyPath *)propertyPath
{
    if (!property) {
        [self removePropertyForPropertPath:propertyPath];
        return;
    }
    
    if (self.propertyDataByPropertyName == nil) {
        self.propertyDataByPropertyName = [NSMutableDictionary new];
    }
    
    if (propertyPath.key) {
        NSMutableDictionary *subDict = self.propertyDataByPropertyName[propertyPath.name];
        if (subDict == nil) {
            subDict = [NSMutableDictionary new];
            self.propertyDataByPropertyName[propertyPath.name] = subDict;
        }
        
        subDict[propertyPath.key] = property;
        return;
    }
    
    self.propertyDataByPropertyName[propertyPath.name] = property;
}

@end
