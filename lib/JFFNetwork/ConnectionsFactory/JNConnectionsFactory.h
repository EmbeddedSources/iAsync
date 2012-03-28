#import <JFFNetwork/JNUrlConnection.h>
#import <Foundation/Foundation.h>

@interface JNConnectionsFactory : NSObject 

@property ( nonatomic, retain, readonly ) NSURL       * url     ;
@property ( nonatomic, retain, readonly ) NSData      * httpBody;
@property ( nonatomic, retain, readonly ) NSString    * httpMethod;
@property ( nonatomic, retain, readonly ) NSDictionary* headers ;

-(id)initWithUrl:( NSURL* ) url_
        httpBody:( NSData* )post_data_
      httpMethod:( NSString* )httpMethod_
         headers:( NSDictionary* )headers_;

-(id< JNUrlConnection >)createFastConnection;
-(id< JNUrlConnection >)createStandardConnection;

@end
