#import "JFFContactField.h"

@interface JFFContactField ()

@property (nonatomic) NSString *name;
@property (nonatomic) ABPropertyID propertyID;

@end

@implementation JFFContactField

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return self;
}

- (instancetype)initWithName:(NSString *)name
                  propertyID:(ABPropertyID)propertyID
                      record:(ABRecordRef)record
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    NSParameterAssert([name length] > 0);
    NSParameterAssert(record != NULL);
    
    _name       = name;
    _propertyID = propertyID;
    _record     = record;
    
    [[self class] addInstanceMethodIfNeedWithSelector:@selector(readProperty)
                                              toClass:[self class]
                                    newMethodSelector:NSSelectorFromString(self.name)];
    [[self class] addInstanceMethodIfNeedWithSelector:@selector(setPropertyFromValue:)
                                              toClass:[self class]
                                    newMethodSelector:NSSelectorFromString([self.name propertySetNameForPropertyName])];
    
    return self;
}

+ (instancetype)newContactFieldWithName:(NSString *)name
                             propertyID:(ABPropertyID)propertyID
                                 record:(ABRecordRef)record
{
    return [[self alloc] initWithName:name
                           propertyID:propertyID
                               record:record];
}

- (id)readProperty
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setPropertyFromValue:(id)value
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
