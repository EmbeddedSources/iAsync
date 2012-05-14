#import "JFFSecureStorage.h"

static NSString* identifier_ = @"Login&Password";

@protocol JFFSecureStorage < NSObject >

-(void)setPassword:( NSString* )password_
             login:( NSString* )login_
            forURL:( NSURL* )url_;

-(NSString*)passwordAndLogin:( NSString** )login_
                      forURL:( NSURL* )url_;

@end

@interface JFFSimulatorSecureStorage : NSObject < JFFSecureStorage >
@end

@implementation JFFSimulatorSecureStorage

+(NSString*)secureStorageFilePath
{
    NSArray* pathes_ = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory
                                                           , NSUserDomainMask
                                                           , YES );
    NSString* documentDirectory_ = [ pathes_ lastObject ];

    return [ documentDirectory_ stringByAppendingPathComponent: @"JFFSimulatorSecureStorage.data" ];
}

-(void)setPassword:( NSString* )password_
             login:( NSString* )login_
            forURL:( NSURL* )url_
{
    NSString* path_ = [ [ self class ] secureStorageFilePath ];

    NSMutableDictionary* dict_ = [ NSMutableDictionary dictionaryWithContentsOfFile: path_ ];
    dict_ = dict_ ?: [ NSMutableDictionary new ];

    NSDictionary* loginPasswordData_ = [ [ NSDictionary alloc ] initWithObjectsAndKeys:
                                        login_     , @"login"
                                        , password_, @"password"
                                        , nil ];

    [ dict_ setObject: loginPasswordData_ forKey: [ url_ description ] ];

    [ dict_ writeToFile: path_ atomically: YES ];
}

-(NSString*)passwordAndLogin:( NSString** )login_
                      forURL:( NSURL* )url_
{
    NSString* path_ = [ [ self class ] secureStorageFilePath ];
    NSDictionary* dict_ = [ NSDictionary dictionaryWithContentsOfFile: path_ ];

    NSDictionary* loginPasswordData_ = [ dict_ objectForKey: [ url_ description ] ];

    if ( login_ )
    {
        *login_ = [ loginPasswordData_ objectForKey: @"login" ];
    }

    return [ loginPasswordData_ objectForKey: @"password" ];
}

@end

@interface JFFDeviceSecureStorage : NSObject < JFFSecureStorage >
{
    NSMutableDictionary* _genericPasswordQuery;
}

@property ( nonatomic, strong, readonly ) NSDictionary* genericPasswordQuery;

@end

@implementation JFFDeviceSecureStorage

@synthesize genericPasswordQuery = _genericPasswordQuery;

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        _genericPasswordQuery = [ NSMutableDictionary new ];

        [ _genericPasswordQuery setObject: identifier_
                                   forKey: (__bridge id)kSecAttrGeneric ];
        [ _genericPasswordQuery setObject: (__bridge id)kSecClassGenericPassword
                                   forKey: (__bridge id)kSecClass ];
        [ _genericPasswordQuery setObject: (__bridge id)kSecMatchLimitOne
                                   forKey: (__bridge id)kSecMatchLimit ];
        [ _genericPasswordQuery setObject: (__bridge id)kCFBooleanTrue
                                   forKey: (__bridge id)kSecReturnAttributes ];
    }

    return self;
}

-(NSString*)passwordFromSecItemFormat:( NSDictionary* )dictionaryToConvert_
{
    NSMutableDictionary* returnDictionary_ =
    [ [ NSMutableDictionary alloc ] initWithDictionary: dictionaryToConvert_ ];

    [ returnDictionary_ setObject: (__bridge id)kCFBooleanTrue
                           forKey: (__bridge id)kSecReturnData ];
    [ returnDictionary_ setObject: (__bridge id)kSecClassGenericPassword
                           forKey: (__bridge id)kSecClass ];

    NSData*   passwordData_ = nil;
    NSString* password_     = nil;

    CFDictionaryRef cfquery_  = (__bridge CFDictionaryRef)returnDictionary_;
    CFDictionaryRef cfresult_ = NULL;

    if ( SecItemCopyMatching( cfquery_, (CFTypeRef*)&cfresult_ ) == noErr)
    {
        passwordData_ = (__bridge_transfer NSData *)cfresult_;

        password_ = [ [ NSString alloc ] initWithBytes: [ passwordData_ bytes ]
                                                length: [ passwordData_ length ] 
                                              encoding: NSUTF8StringEncoding ];
    }
    else
    {
        NSAssert( NO, @"Serious error, no matching item found in the keychain.\n" );
    }

    return password_;
}

-(NSString*)passwordAndLogin:( NSString** )login_
           fromSecItemFormat:( NSDictionary* )dictionaryToConvert_
{
    if ( login_ )
    {
        *login_ = [ dictionaryToConvert_ objectForKey: (__bridge id)kSecAttrAccount ];
        NSLog( @"*login_: %@", *login_ );
    }

    return [ self passwordFromSecItemFormat: dictionaryToConvert_ ];
}

-(NSMutableDictionary*)dictionaryToSecItemFormat:( NSDictionary* )dictionaryToConvert_
{
    NSMutableDictionary* returnDictionary_ =
    [ [ NSMutableDictionary alloc ] initWithDictionary: dictionaryToConvert_ ];

    NSString* passwordString_ = [ dictionaryToConvert_ objectForKey: (__bridge id)kSecValueData ];
    NSString* urlString_      = [ [ dictionaryToConvert_ objectForKey: (__bridge id)kSecAttrService ] description ];

    [ returnDictionary_ setObject: [ passwordString_ dataUsingEncoding: NSUTF8StringEncoding ]
                           forKey: (__bridge id)kSecValueData ];
    [ returnDictionary_ setObject: urlString_
                           forKey: (__bridge id)kSecAttrService ];

    return returnDictionary_;
}

-(NSMutableDictionary*)defaultKeychainItemData
{
    NSMutableDictionary* result_ = [ NSMutableDictionary new ];

    // Default attributes for keychain item.
    [ result_ setObject: @"" forKey: (__bridge id)kSecAttrAccount ];
    [ result_ setObject: @"" forKey: (__bridge id)kSecAttrLabel ];
    [ result_ setObject: @"" forKey: (__bridge id)kSecAttrDescription ];

    // Default data for keychain item.
    [ result_ setObject: @"" forKey: (__bridge id)kSecValueData ];
    [ result_ setObject: identifier_ forKey: (__bridge id)kSecAttrGeneric ];

    return result_;
}

-(NSDictionary*)queryForURL:( NSURL* )url_
{
    NSMutableDictionary* result_ =
        [ [ NSMutableDictionary alloc ] initWithDictionary: self.genericPasswordQuery ];
    [ result_ setObject: [ url_ description ] forKey: (__bridge id)kSecAttrService ];
    return [ [ NSDictionary alloc ] initWithDictionary: result_ ];
}

-(void)writeToKeychainLogin:( NSString* )login_
                        url:( NSURL* )url_
                   password:( NSString* )password_
{
    if ( [ login_ length ] == 0 )
        return;

    NSMutableDictionary* keychainItemData_ = [ self defaultKeychainItemData ];

    [ keychainItemData_ setObject: login_    forKey: (__bridge id)kSecAttrAccount ];
    [ keychainItemData_ setObject: password_ forKey: (__bridge id)kSecValueData   ];
    [ keychainItemData_ setObject: url_      forKey: (__bridge id)kSecAttrService ];
    [ keychainItemData_ setObject: (__bridge id)kSecAttrAccessibleWhenUnlocked 
                           forKey: (__bridge id)kSecAttrAccessible ];

    NSMutableDictionary* updateItem_ = nil;

    NSDictionary* tempQuery_ = [ self queryForURL: url_ ];

    CFDictionaryRef cfquery_  = (__bridge_retained CFDictionaryRef)tempQuery_;
    CFDictionaryRef cfresult_ = NULL;

    NSMutableDictionary* secDictionary_ = [ self dictionaryToSecItemFormat: keychainItemData_ ];

    if ( SecItemCopyMatching( cfquery_, (CFTypeRef *)&cfresult_) == noErr )
    {
        NSDictionary* attributes_ = (__bridge_transfer NSDictionary *)cfresult_;

        updateItem_ = [ [ NSMutableDictionary alloc ] initWithDictionary: attributes_ ];
        [ updateItem_ setObject: (__bridge id)kSecClassGenericPassword forKey: (__bridge id)kSecClass ];

        CFDictionaryRef cfSecDictionary_ = (__bridge_retained CFDictionaryRef)secDictionary_;
        CFDictionaryRef cfUpdateItem_    = (__bridge_retained CFDictionaryRef)updateItem_;

        BOOL result_ = SecItemUpdate( cfUpdateItem_, cfSecDictionary_ ) == noErr;
        NSAssert( result_, @"Couldn't update the Keychain Item." );
        CFRelease( cfSecDictionary_ );
        CFRelease( cfUpdateItem_ );
    }
    else
    {
        // No previous item found, add the new one.
        [ secDictionary_ setObject: (__bridge id)kSecClassGenericPassword forKey: (__bridge id)kSecClass ];

        CFDictionaryRef cfSecDictionary_ = (__bridge_retained CFDictionaryRef)secDictionary_;

        BOOL result_ = SecItemAdd(cfSecDictionary_, nil ) == noErr;
        NSAssert( result_, @"Couldn't add the Keychain Item." );
        CFRelease( cfSecDictionary_ );
    }

    CFRelease( cfquery_ );
}

-(NSString*)findPasswordAndLogin:( NSString** )login_
                          forUrl:( NSURL* )url_
{
    NSString* result_ = nil;

    NSDictionary* tempQuery_ = [ self queryForURL: url_ ];

    CFDictionaryRef cfquery_  = (__bridge CFDictionaryRef)tempQuery_;
    CFDictionaryRef cfresult_ = NULL;

    if ( SecItemCopyMatching( cfquery_, (CFTypeRef*)&cfresult_) == noErr )
    {
        NSDictionary* outDictionary_ = (__bridge_transfer NSDictionary *)cfresult_;
        result_ = [ self passwordAndLogin: login_
                        fromSecItemFormat: outDictionary_ ];
    }

    return result_;
}

-(void)setPassword:( NSString* )password_
             login:( NSString* )login_
            forURL:( NSURL* )url_
{
    [ self writeToKeychainLogin: login_
                            url: url_
                       password: password_ ];
}

-(NSString*)passwordAndLogin:( NSString** )login_
                      forURL:( NSURL* )url_
{
    return [ self findPasswordAndLogin: login_
                                forUrl: url_ ];
}

@end

@interface JFFSecureStorage ()

@property ( nonatomic, strong ) id< JFFSecureStorage > secureStorage;

@end

@implementation JFFSecureStorage

@synthesize secureStorage = _secureStorage;

-(id)init
{
    self = [ super init ];

    if ( self )
    {
#if TARGET_IPHONE_SIMULATOR
        self->_secureStorage = [ JFFSimulatorSecureStorage new ];
#else
        self->_secureStorage = [ JFFDeviceSecureStorage new ];
#endif
    }

    return self;
}

-(void)setPassword:( NSString* )password_
             login:( NSString* )login_
            forURL:( NSURL* )url_
{
    NSParameterAssert( url_ );

    login_    = login_    ?: @"";
    password_ = password_ ?: @"";

    [ self.secureStorage setPassword: password_
                               login: login_
                              forURL: url_ ];
}

-(NSString*)passwordAndLogin:( NSString** )login_
                      forURL:( NSURL* )url_
{
    NSParameterAssert( url_ );

    return [ self.secureStorage passwordAndLogin: login_
                                          forURL: url_ ];
}

@end
