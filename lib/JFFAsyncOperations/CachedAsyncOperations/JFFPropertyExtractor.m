#import "JFFPropertyExtractor.h"

#import "JFFPropertyPath.h"
#import "JFFObjectRelatedPropertyData.h"

#import "NSObject+PropertyExtractor.h"

#import <JFFUtils/MemoryManagement/JFFMemoryMgmt.h>

#import <objc/message.h>

@interface JFFPropertyExtractor ()

@property ( nonatomic ) JFFObjectRelatedPropertyData* objectPropertyData;

@end

@implementation JFFPropertyExtractor
{
    SEL _propertyGetSelector;
    SEL _propertySetSelector;
}

@dynamic delegates
, asyncLoader
, didFinishBlock
, cancelBlock;

-(void)clearData
{
    self.objectPropertyData = nil;

    jff_retainAutorelease(self->_object);
    self->_object = nil;
    //self.propertyPath = nil;
}

-(SEL)propertyGetSelector
{
    if (!self->_propertyGetSelector)
    {
        self->_propertyGetSelector = NSSelectorFromString(self.propertyPath.name);
    }
    return self->_propertyGetSelector;
}

-(SEL)propertySetSelector
{
    if ( !self->_propertySetSelector )
    {
        NSString* setPropertyName_ = [ self.propertyPath.name propertySetNameForPropertyName ];
        self->_propertySetSelector = NSSelectorFromString( setPropertyName_ );
    }
    return self->_propertySetSelector;
}

- (id)property
{
    id result_ = objc_msgSend( self.object, self.propertyGetSelector );
    return self.propertyPath.key?[result_ objectForKey:self.propertyPath.key]:result_;
}

- (void)setProperty:(id)property
{
    if (!self.propertyPath.key)
    {
        objc_msgSend(self.object, self.propertySetSelector, property);
        return;
    }

    NSMutableDictionary* dict = objc_msgSend(self.object, self.propertyGetSelector);

    if ( !dict )
    {
        dict = [NSMutableDictionary new];
        objc_msgSend(self.object, self.propertySetSelector, dict);
    }

    if (property)
    {
        [dict setObject:property forKey:self.propertyPath.key];
        return;
    }

    [dict removeObjectForKey:self.propertyPath.key];
}

////////////////////////OBJECT RELATED DATA///////////////////////

- (JFFObjectRelatedPropertyData*)objectPropertyData
{
    JFFObjectRelatedPropertyData* data = [self.object propertyDataForPropertPath:self.propertyPath];
    if (!data)
    {
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
