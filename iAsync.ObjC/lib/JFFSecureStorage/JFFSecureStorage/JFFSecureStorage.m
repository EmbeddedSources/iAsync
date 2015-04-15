#import "JFFSecureStorage.h"

#import <JFFUtils/JFFClangLiterals.h>

#include <assert.h>

static NSString* const __identifier = @"Login&Password";

// TODO : Rewrite in C++. This can be easily reversed by tools like class_dump_z
// http://code.google.com/p/networkpx/wiki/class_dump_z

@protocol JFFSecureStorage < NSObject >

- (void)setPassword:(NSString *)password
              login:(NSString *)login
             forURL:(NSURL *)url;

- (NSString *)passwordAndLogin:(NSString **)login
                        forURL:(NSURL *)url;

@end

@interface JFFSimulatorSecureStorage : NSObject <JFFSecureStorage>
@end

@implementation JFFSimulatorSecureStorage

+ (NSString *)secureStorageFilePath
{
    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                          NSUserDomainMask,
                                                          YES);
    NSString *documentDirectory = [pathes lastObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"JFFSimulatorSecureStorage.data"];
}

- (void)setPassword:(NSString *)password
              login:(NSString *)login
             forURL:(NSURL *)url
{
    NSString *path = [[self class] secureStorageFilePath];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    dict = dict ?: [NSMutableDictionary new];
    
    NSDictionary *loginPasswordData = @{@"login" : login, @"password" : password};
    
    dict[[url description]] = loginPasswordData;
    
    [dict writeToFile:path atomically:YES];
}

- (NSString *)passwordAndLogin:(NSString **)login
                        forURL:(NSURL *)url
{
    NSString *path = [[self class] secureStorageFilePath];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSDictionary *loginPasswordData = dict[[url description]];
    
    if (login) {
        
        *login = loginPasswordData[@"login"];
    }
    
    return loginPasswordData[@"password"];
}

@end

@interface JFFDeviceSecureStorage : NSObject < JFFSecureStorage >
{
    NSMutableDictionary *_genericPasswordQuery;
}

@property (nonatomic, readonly) NSDictionary *genericPasswordQuery;

@end

@implementation JFFDeviceSecureStorage

- (id)init
{
    self = [super init];
    
    if ( self ) {
        
        self->_genericPasswordQuery = [NSMutableDictionary new];
        
        self->_genericPasswordQuery[(__bridge id)kSecAttrGeneric     ] = __identifier;
        self->_genericPasswordQuery[(__bridge id)kSecClass           ] = (__bridge id)kSecClassGenericPassword;
        self->_genericPasswordQuery[(__bridge id)kSecMatchLimit      ] = (__bridge id)kSecMatchLimitOne;
        self->_genericPasswordQuery[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    }

    return self;
}

- (NSString *)passwordFromSecItemFormat:(NSDictionary *)dictionaryToConvert
{
    NSMutableDictionary *returnDictionary = [dictionaryToConvert mutableCopy];
    
    returnDictionary[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    returnDictionary[(__bridge id)kSecClass     ] = (__bridge id)kSecClassGenericPassword;
    
    NSData   *passwordData = nil;
    NSString *password     = nil;
    
    CFDictionaryRef cfquery  = (__bridge CFDictionaryRef)returnDictionary;
    CFDictionaryRef cfresult = NULL;
    
    if (SecItemCopyMatching(cfquery, (CFTypeRef*)&cfresult) == noErr) {
        
        passwordData = (__bridge_transfer NSData *)cfresult;
        
        password = [[NSString alloc] initWithBytes:[passwordData bytes]
                                            length:[passwordData length]
                                          encoding:NSUTF8StringEncoding];
        
    } else {
        NSAssert( NO, @"Serious error, no matching item found in the keychain.\n" );
    }
    
    return password;
}

- (NSString *)passwordAndLogin:(NSString **)login
             fromSecItemFormat:(NSDictionary *)dictionaryToConvert
{
    if (login) {
        
        *login = dictionaryToConvert[(__bridge id)kSecAttrAccount];
        NSLog(@"*login_: %@", *login);
    }
    
    return [self passwordFromSecItemFormat:dictionaryToConvert];
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
    NSMutableDictionary* result = [ NSMutableDictionary new ];
    
    // Default attributes for keychain item.
    result[(__bridge id)kSecAttrAccount    ] = @"";
    result[(__bridge id)kSecAttrLabel      ] = @"";
    result[(__bridge id)kSecAttrDescription] = @"";
    
    // Default data for keychain item.
    result[(__bridge id)kSecValueData  ] = @"";
    result[(__bridge id)kSecAttrGeneric] = __identifier;
    
    return result;
}

- (NSDictionary *)queryForURL:(NSURL *)url
{
    NSMutableDictionary *result = [self.genericPasswordQuery mutableCopy];
    result[(__bridge id)kSecAttrService] = [url description];
    return [result copy];
}

- (void)writeToKeychainLogin:(NSString *)login
                         url:(NSURL *)url
                    password:(NSString *)password
{
    if ([login length] == 0)
        return;
    
    NSMutableDictionary *keychainItemData = [self defaultKeychainItemData];
    
    keychainItemData[(__bridge id)kSecAttrAccount   ] = login;
    keychainItemData[(__bridge id)kSecValueData     ] = password;
    keychainItemData[(__bridge id)kSecAttrService   ] = url;
    keychainItemData[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
    
    NSMutableDictionary *updateItem= nil;
    
    NSDictionary *tempQuery = [self queryForURL:url];
    
    CFDictionaryRef cfquery  = (__bridge_retained CFDictionaryRef)tempQuery;
    CFDictionaryRef cfresult = NULL;
    
    NSMutableDictionary* secDictionary = [ self dictionaryToSecItemFormat: keychainItemData ];
    
    if (SecItemCopyMatching(cfquery, (CFTypeRef *)&cfresult) == noErr) {
        
        NSDictionary *attributes = (__bridge_transfer NSDictionary *)cfresult;
        
        updateItem = [attributes mutableCopy];
        updateItem[ (__bridge id)kSecClass ] = (__bridge id)kSecClassGenericPassword;
        
        CFDictionaryRef cfSecDictionary = (__bridge_retained CFDictionaryRef)secDictionary;
        CFDictionaryRef cfUpdateItem    = (__bridge_retained CFDictionaryRef)updateItem;
        
        BOOL result_ = SecItemUpdate(cfUpdateItem, cfSecDictionary) == noErr;
        NSAssert( result_, @"Couldn't update the Keychain Item." );
        CFRelease( cfSecDictionary );
        CFRelease( cfUpdateItem );
    }
    else
    {
        // No previous item found, add the new one.
        secDictionary[ (__bridge id)kSecClass ] = (__bridge id)kSecClassGenericPassword;
        
        CFDictionaryRef cfSecDictionary_ = (__bridge_retained CFDictionaryRef)secDictionary;
        
        BOOL result_ = SecItemAdd(cfSecDictionary_, nil ) == noErr;
        NSAssert( result_, @"Couldn't add the Keychain Item." );
        CFRelease( cfSecDictionary_ );
    }

    CFRelease( cfquery );
}

- (NSString *)findPasswordAndLogin:(NSString **)login
                            forUrl:(NSURL *)url
{
    NSString *result_ = nil;
    
    NSDictionary *tempQuery = [self queryForURL:url];
    
    CFDictionaryRef cfquery  = (__bridge CFDictionaryRef)tempQuery;
    CFDictionaryRef cfresult = NULL;
    
    if ( SecItemCopyMatching( cfquery, (CFTypeRef*)&cfresult) == noErr )
    {
        NSDictionary* outDictionary_ = (__bridge_transfer NSDictionary *)cfresult;
        result_ = [ self passwordAndLogin: login
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
