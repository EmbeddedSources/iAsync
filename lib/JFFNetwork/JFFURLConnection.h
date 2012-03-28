#import <JFFNetwork/JNUrlConnection.h>
#import <JFFNetwork/JNUrlConnectionCallbacks.h>
#import <JFFNetwork/JNAbstractConnection.h>
#import <Foundation/Foundation.h>

//JFFURLConnection can not be reused after cancel or finish
//all callbacks cleared after cancel or finish action
@interface JFFURLConnection : JNAbstractConnection

+(id)connectionWithURL:( NSURL* )url_
              httpBody:( NSData* )data_
            httpMethod:( NSString* )httpMethod_
           contentType:( NSString* )content_type_;

+(id)connectionWithURL:( NSURL* )url_
              httpBody:( NSData* )data_
            httpMethod:( NSString* )httpMethod_
               headers:( NSDictionary* )headers_;

-(void)start;
-(void)cancel;

@end
