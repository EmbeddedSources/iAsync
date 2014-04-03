#import "JFFPropertyExtractor.h"

#import "JFFPropertyPath.h"
#import "JFFObjectRelatedPropertyData.h"

#import "NSObject+PropertyExtractor.h"

#import <JFFUtils/MemoryManagement/JFFMemoryMgmt.h>

#import <objc/message.h>

//#define JFF_LOG_INFO( ... )
#define JFF_LOG_INFO( ... ) [ JFFLogger logInfoWithFormat: __VA_ARGS__ ]

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
    JFF_LOG_INFO( @"[BEGIN] %@", methodNameForLogging );
    
    if (!_propertySetSelector) {
        NSString* propertyPathName = self.propertyPath.name;
        
        NSString *setPropertyName = [ propertyPathName propertySetNameForPropertyName];
        _propertySetSelector = NSSelectorFromString(setPropertyName);
        
        JFF_LOG_INFO( @"setPropertyName : %@", setPropertyName );
        JFF_LOG_INFO( @"result : %p", _propertySetSelector );
    }
    
    JFF_LOG_INFO(  @"[END] %@", methodNameForLogging );
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
    
    JFF_LOG_INFO( @"[BEGIN] %@", methodNameForLogging );
    JFF_LOG_INFO( @"property : %@", property );
    JFF_LOG_INFO( @"self.object : %@", self.object );
    JFF_LOG_INFO( @"self.propertyPath : (%@ --> %@)", self.propertyPath.key, self.propertyPath.name  );
    
    SEL propertySetSelector = self.propertySetSelector;
    JFF_LOG_INFO( @"self.propertySetSelector : %p", propertySetSelector );
    
    if (!self.propertyPath.key) {
        JFF_LOG_INFO( @"---" );
        JFF_LOG_INFO( @"propertyPath.key is nil" );
        JFF_LOG_INFO( @"setting property by name..." );
        
        FPropertySetter( self.object, propertySetSelector, property );
        
        JFF_LOG_INFO( @"===[END1] %@", methodNameForLogging );
        return;
    }
    
    JFF_LOG_INFO( @"getting dict..." );
    NSMutableDictionary* dict = FPropertyGetter(self.object, self.propertyGetSelector);
    
    JFF_LOG_INFO( @"---" );
    if (!dict) {
        JFF_LOG_INFO( @"dict is nil. Setting an empty one..." );
        dict = [NSMutableDictionary new];
        FPropertySetter(self.object, self.propertySetSelector, dict);
    }
    
    if (property) {
        JFF_LOG_INFO( @"setting property by key..." );
        [ dict setObject: property
                  forKey: self.propertyPath.key ];

        JFF_LOG_INFO( @"===[END2] %@", methodNameForLogging );
        return;
    }

    JFF_LOG_INFO( @"removing key from dict..." );
    [ dict removeObjectForKey: self.propertyPath.key ];
    
    JFF_LOG_INFO( @"===[END] %@", methodNameForLogging );
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
