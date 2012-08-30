#import "JFFSecureStorage.h"

#import <JFFUtils/JFFClangLiterals.h>

#include <assert.h>

static NSString* const identifier_ = @"Login&Password";

// TODO : Rewrite in C++. This can be easily reversed by tools like class_dump_z
// http://code.google.com/p/networkpx/wiki/class_dump_z

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

    NSMutableDictionary* dict_ = [ [ NSMutableDictionary alloc ] initWithContentsOfFile: path_ ];
    dict_ = dict_ ?: [ NSMutableDictionary new ];

    NSDictionary* loginPasswordData_ = @{ @"login" : login_, @"password" : password_ };

    dict_[ [ url_ description ] ] = loginPasswordData_;

    [ dict_ writeToFile: path_ atomically: YES ];
}

-(NSString*)passwordAndLogin:( NSString** )login_
                      forURL:( NSURL* )url_
{
    NSString* path_ = [ [ self class ] secureStorageFilePath ];
    NSDictionary* dict_ = [ [ NSDictionary alloc ] initWithContentsOfFile: path_ ];

    NSDictionary* loginPasswordData_ = dict_[ [ url_ description ] ];

    if ( login_ )
    {
        *login_ = loginPasswordData_[ @"login" ];
    }

    return loginPasswordData_[ @"password" ];
}

@end

@interface JFFDeviceSecureStorage : NSObject < JFFSecureStorage >
{
    NSMutableDictionary* _genericPasswordQuery;
}

@property ( nonatomic, readonly ) NSDictionary* genericPasswordQuery;

@end

@implementation JFFDeviceSecureStorage

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        self->_genericPasswordQuery = [ NSMutableDictionary new ];

        self->_genericPasswordQuery[ (__bridge id)kSecAttrGeneric      ] = identifier_;
        self->_genericPasswordQuery[ (__bridge id)kSecClass            ] = (__bridge id)kSecClassGenericPassword;
        self->_genericPasswordQuery[ (__bridge id)kSecMatchLimit       ] = (__bridge id)kSecMatchLimitOne;
        self->_genericPasswordQuery[ (__bridge id)kSecReturnAttributes ] = (__bridge id)kCFBooleanTrue;
    }

    return self;
}

-(NSString*)passwordFromSecItemFormat:( NSDictionary* )dictionaryToConvert_
{
    NSMutableDictionary* returnDictionary_ = [ dictionaryToConvert_ mutableCopy ];

    returnDictionary_[ (__bridge id)kSecReturnData ] = (__bridge id)kCFBooleanTrue;
    returnDictionary_[ (__bridge id)kSecClass      ] = (__bridge id)kSecClassGenericPassword;

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
        *login_ = dictionaryToConvert_[ (__bridge id)kSecAttrAccount ];
        NSLog( @"*login_: %@", *login_ );
    }

    return [ self passwordFromSecItemFormat: dictionaryToConvert_ ];
}

-(NSMutableDictionary*)dictionaryToSecItemFormat:( NSDictionary* )dictionaryToConvert_
{
    NSMutableDictionary* returnDictionary_ = [ dictionaryToConvert_ mutableCopy ];

    NSString* passwordString_ = dictionaryToConvert_[ (__bridge id)kSecValueData ];
    NSString* urlString_      = [ dictionaryToConvert_[ (__bridge id)kSecAttrService ] description ];

    returnDictionary_[ (__bridge id)kSecValueData   ] = [ passwordString_ dataUsingEncoding: NSUTF8StringEncoding ];
    returnDictionary_[ (__bridge id)kSecAttrService ] = urlString_;

    return returnDictionary_;
}

-(NSMutableDictionary*)defaultKeychainItemData
{
    NSMutableDictionary* result_ = [ NSMutableDictionary new ];

    // Default attributes for keychain item.
    result_[ (__bridge id)kSecAttrAccount     ] = @"";
    result_[ (__bridge id)kSecAttrLabel       ] = @"";
    result_[ (__bridge id)kSecAttrDescription ] = @"";

    // Default data for keychain item.
    result_[ (__bridge id)kSecValueData   ] = @"";
    result_[ (__bridge id)kSecAttrGeneric ] = identifier_;

    return result_;
}

-(NSDictionary*)queryForURL:( NSURL* )url_
{
    NSMutableDictionary* result_ = [ self.genericPasswordQuery mutableCopy ];
    result_[ (__bridge id)kSecAttrService ] = [ url_ description ];
    return [ result_ copy ];
}

-(void)writeToKeychainLogin:( NSString* )login_
                        url:( NSURL* )url_
                   password:( NSString* )password_
{
    if ( [ login_ length ] == 0 )
        return;

    NSMutableDictionary* keychainItemData_ = [ self defaultKeychainItemData ];

    keychainItemData_[ (__bridge id)kSecAttrAccount    ] = login_;
    keychainItemData_[ (__bridge id)kSecValueData      ] = password_;
    keychainItemData_[ (__bridge id)kSecAttrService    ] = url_;
    keychainItemData_[ (__bridge id)kSecAttrAccessible ] = (__bridge id)kSecAttrAccessibleWhenUnlocked;

    NSMutableDictionary* updateItem_ = nil;

    NSDictionary* tempQuery_ = [ self queryForURL: url_ ];

    CFDictionaryRef cfquery_  = (__bridge_retained CFDictionaryRef)tempQuery_;
    CFDictionaryRef cfresult_ = NULL;

    NSMutableDictionary* secDictionary_ = [ self dictionaryToSecItemFormat: keychainItemData_ ];

    if ( SecItemCopyMatching( cfquery_, (CFTypeRef *)&cfresult_) == noErr )
    {
        NSDictionary* attributes_ = (__bridge_transfer NSDictionary *)cfresult_;

        updateItem_ = [ attributes_ mutableCopy ];
        updateItem_[ (__bridge id)kSecClass ] = (__bridge id)kSecClassGenericPassword;

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
        secDictionary_[ (__bridge id)kSecClass ] = (__bridge id)kSecClassGenericPassword;

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

static id< JFFSecureStorage > secureStorage( void )
{
    static id< JFFSecureStorage > result_;
    if ( !result_ )
    {
        result_ =
#if TARGET_IPHONE_SIMULATOR
        [ JFFSimulatorSecureStorage new ];
#else
        [ JFFDeviceSecureStorage new ];
#endif
    }
    return result_;
}

void jffStoreSecureCredentials( NSString* login_
                               , NSString* password_
                               , NSURL* url_ )
{
    assert( url_ );

    login_    = login_    ?: @"";
    password_ = password_ ?: @"";

    [ secureStorage() setPassword: password_
                            login: login_
                           forURL: url_ ];
}

NSString* jffGetSecureCredentialsForURL( NSString** login_
                                        , NSURL* url_ )
{
    assert( url_ );

    return [ secureStorage() passwordAndLogin: login_
                                       forURL: url_ ];
}
