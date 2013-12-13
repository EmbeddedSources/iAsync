#import "JFFPropertyExtractor.h"

#import "JFFPropertyPath.h"
#import "JFFObjectRelatedPropertyData.h"

#import "NSObject+PropertyExtractor.h"

#import <JFFUtils/MemoryManagement/JFFMemoryMgmt.h>

#import <objc/message.h>

@interface JFFPropertyExtractor ()

@property (nonatomic) JFFObjectRelatedPropertyData *objectPropertyData;

@end

@implementation JFFPropertyExtractor
{
    SEL _propertyGetSelector;
    SEL _propertySetSelector;
}

@dynamic
delegates,
asyncLoader,
didFinishBlock,
loaderHandler;

- (void)clearData
{
    self.objectPropertyData = nil;
    
    jff_retainAutorelease(_object);
    _object = nil;
    //self.propertyPath = nil;
}

- (SEL)propertyGetSelector
{
    if (!_propertyGetSelector) {
        _propertyGetSelector = NSSelectorFromString(self.propertyPath.name);
    }
    return _propertyGetSelector;
}

- (SEL)propertySetSelector
{
    if (!_propertySetSelector) {
        NSString *setPropertyName = [self.propertyPath.name propertySetNameForPropertyName];
        _propertySetSelector = NSSelectorFromString(setPropertyName);
    }
    return _propertySetSelector;
}

- (id)property
{
    id result = objc_msgSend(self.object, self.propertyGetSelector);
    return self.propertyPath.key?[result objectForKey:self.propertyPath.key]:result;
}

- (void)setProperty:(id)property
{
    if (!self.propertyPath.key) {
        objc_msgSend(self.object, self.propertySetSelector, property);
        return;
    }
    
    NSMutableDictionary* dict = objc_msgSend(self.object, self.propertyGetSelector);
    
    if (!dict) {
        dict = [NSMutableDictionary new];
        objc_msgSend(self.object, self.propertySetSelector, dict);
    }
    
    if (property) {
        [dict setObject:property forKey:self.propertyPath.key];
        return;
    }
    
    [dict removeObjectForKey:self.propertyPath.key];
}

////////////////////////OBJECT RELATED DATA///////////////////////

- (JFFObjectRelatedPropertyData *)objectPropertyData
{
    JFFObjectRelatedPropertyData *data = [self.object propertyDataForPropertPath:self.propertyPath];
    if (!data) {
        data = [JFFObjectRelatedPropertyData new];
        [self.object setPropertyData:data forPropertPath:self.propertyPath];
    }
    return data;
}

- (void)setObjectPropertyData:(JFFObjectRelatedPropertyData *)objectPropertyData
{
    [self.object setPropertyData:objectPropertyData forPropertPath:self.propertyPath];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    return self.objectPropertyData;
}

@end
