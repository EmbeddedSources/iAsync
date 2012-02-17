#import <JFFNetwork/JNUrlConnection.h>
#import <Foundation/Foundation.h>

@interface JNConnectionsFactory : NSObject 

@property ( nonatomic, retain, readonly ) NSURL       * url     ;
@property ( nonatomic, retain, readonly ) NSData      * postData;
@property ( nonatomic, retain, readonly ) NSDictionary* headers ;

-(id)initWithUrl:( NSURL* ) url_
        postData:( NSData* )post_data_
         headers:( NSDictionary* )headers_;

-(id< JNUrlConnection >)createFastConnection;
-(id< JNUrlConnection >)createStandardConnection;

@end
