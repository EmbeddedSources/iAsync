#import "JFFPropertyExtractor.h"

#import "JFFPropertyPath.h"
#import "JFFObjectRelatedPropertyData.h"

#import "NSObject+PropertyExtractor.h"

#import <JFFUtils/MemoryManagement/JFFMemoryMgmt.h>

#import <objc/message.h>

@interface JFFPropertyExtractor ()

@property ( nonatomic, strong ) JFFObjectRelatedPropertyData* objectPropertyData;

@end

@implementation JFFPropertyExtractor
{
    SEL _propertyGetSelector;
    SEL _propertySetSelector;
}

@synthesize propertyPath = _propertyPath;
@synthesize object = _object;

@dynamic delegates
, asyncLoader
, didFinishBlock
, cancelBlock;

-(void)clearData
{
    self.objectPropertyData = nil;

    jff_retainAutorelease( _object );
    _object = nil;
    //self.propertyPath = nil;
}

-(SEL)propertyGetSelector
{
    if ( !_propertyGetSelector )
    {
        _propertyGetSelector = NSSelectorFromString( self.propertyPath.name );
    }
    return _propertyGetSelector;
}

-(SEL)propertySetSelector
{
    if ( !_propertySetSelector )
    {
        NSString* setPropertyName_ = [ self.propertyPath.name propertySetNameForPropertyName ];
        _propertySetSelector = NSSelectorFromString( setPropertyName_ );
    }
    return _propertySetSelector;
}

-(id)property
{
    id result_ = objc_msgSend( self.object, self.propertyGetSelector );
    return self.propertyPath.key ? [ result_ objectForKey: self.propertyPath.key ] : result_;
}

-(void)setProperty:( id )property_
{
    if ( !self.propertyPath.key )
    {
        objc_msgSend( self.object, self.propertySetSelector, property_ );
        return;
    }

    NSMutableDictionary* dict_ = objc_msgSend( self.object, self.propertyGetSelector );

    if ( !dict_ )
    {
        dict_ = [ NSMutableDictionary new ];
        objc_msgSend( self.object, self.propertySetSelector, dict_ );
    }

    if ( property_ )
    {
        [ dict_ setObject: property_ forKey: self.propertyPath.key ];
        return;
    }

    [ dict_ removeObjectForKey: self.propertyPath.key ];
}

////////////////////////OBJECT RELATED DATA///////////////////////

-(JFFObjectRelatedPropertyData*)objectPropertyData
{
    JFFObjectRelatedPropertyData* data_ = [ self.object propertyDataForPropertPath: self.propertyPath ];
    if ( !data_ )
    {
        data_ = [ JFFObjectRelatedPropertyData new ];
        [ self.object setPropertyData: data_ forPropertPath: self.propertyPath ];
    }
    return data_;
}

-(void)setObjectPropertyData:( JFFObjectRelatedPropertyData* )object_property_data_
{
    [ self.object setPropertyData: object_property_data_ forPropertPath: self.propertyPath ];
}

-(id)forwardingTargetForSelector:( SEL )selector_
{
    return self.objectPropertyData;
}

@end
