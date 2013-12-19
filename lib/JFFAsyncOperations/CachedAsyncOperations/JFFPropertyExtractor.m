#import "JFFPropertyExtractor.h"

#import "JFFPropertyPath.h"
#import "JFFObjectRelatedPropertyData.h"

#import "NSObject+PropertyExtractor.h"

#import <JFFUtils/MemoryManagement/JFFMemoryMgmt.h>

#import <objc/message.h>


typedef id (*PropertyGetterMsgSendFunction)( id, SEL );
typedef void (*PropertySetterMsgSendFunction)( id, SEL, id );

static const PropertyGetterMsgSendFunction FPropertyGetter = (PropertyGetterMsgSendFunction)objc_msgSend;
static const PropertySetterMsgSendFunction FPropertySetter = (PropertySetterMsgSendFunction)objc_msgSend;


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
cancelBlock;

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
    NSString* methodNameForLogging = NSStringFromSelector( _cmd );
    [ JFFLogger logInfoWithFormat: @"[BEGIN] %@", methodNameForLogging ];
    
    if (!_propertySetSelector) {
        NSString* propertyPathName = self.propertyPath.name;
        
        NSString *setPropertyName = [ propertyPathName propertySetNameForPropertyName];
        _propertySetSelector = NSSelectorFromString(setPropertyName);
        
        [ JFFLogger logInfoWithFormat: @"setPropertyName : %@", setPropertyName ];
        [ JFFLogger logInfoWithFormat: @"result : %p", _propertySetSelector ];
    }
    
    [ JFFLogger logInfoWithFormat: @"[END] %@", methodNameForLogging ];
    return _propertySetSelector;
}

-(id)property
{
    id result = FPropertyGetter(self.object, self.propertyGetSelector);
    return self.propertyPath.key?[result objectForKey:self.propertyPath.key]:result;
}


- (void)setProperty:(id)property
{
    NSString* methodNameForLogging = NSStringFromSelector( _cmd );
    
    [ JFFLogger logInfoWithFormat: @"[BEGIN] %@", methodNameForLogging ];
    [ JFFLogger logInfoWithFormat: @"property : %@", property ];
    [ JFFLogger logInfoWithFormat: @"self.object : %@", self.object ];
    [ JFFLogger logInfoWithFormat: @"self.propertyPath : (%@ --> %@)", self.propertyPath.key, self.propertyPath.name  ];
    
    SEL propertySetSelector = self.propertySetSelector;
    [ JFFLogger logInfoWithFormat: @"self.propertySetSelector : %p", propertySetSelector ];
    
    if (!self.propertyPath.key) {
        [ JFFLogger logInfoWithFormat: @"---" ];
        [ JFFLogger logInfoWithFormat: @"propertyPath.key is nil" ];
        [ JFFLogger logInfoWithFormat: @"setting property by name..." ];
        
        FPropertySetter( self.object, propertySetSelector, property );
        
        [ JFFLogger logInfoWithFormat: @"===[END1] %@", methodNameForLogging ];
        return;
    }
    
    [ JFFLogger logInfoWithFormat: @"getting dict..." ];
    NSMutableDictionary* dict = FPropertyGetter(self.object, self.propertyGetSelector);
    
    [ JFFLogger logInfoWithFormat: @"---" ];
    if (!dict) {
        [ JFFLogger logInfoWithFormat: @"dict is nil. Setting an empty one..." ];
        dict = [NSMutableDictionary new];
        FPropertySetter(self.object, self.propertySetSelector, dict);
    }
    
    if (property) {
        [ JFFLogger logInfoWithFormat: @"setting property by key..." ];
        [ dict setObject: property
                  forKey: self.propertyPath.key ];

        [ JFFLogger logInfoWithFormat: @"===[END2] %@", methodNameForLogging ];
        return;
    }

    [ JFFLogger logInfoWithFormat: @"removing key from dict..." ];
    [ dict removeObjectForKey: self.propertyPath.key ];
    
    [ JFFLogger logInfoWithFormat: @"===[END] %@", methodNameForLogging ];
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
