#import <JFFNetwork/JNUrlConnection.h>
#import <JFFNetwork/JNUrlConnectionCallbacks.h>
#import <JFFNetwork/JNAbstractConnection.h>
#import <Foundation/Foundation.h>

//ESURLConnection can not be reused after cancel or finish
//all callbacks cleared after cancel or finish action
@interface JFFURLConnection : JNAbstractConnection
{
@private
   NSData* _post_data;
   NSDictionary* _headers;

   BOOL _response_handled;
   CFReadStreamRef _read_stream;
   NSURL* _url;
}

+(id)connectionWithURL:( NSURL* )url_
              postData:( NSData* )data_
           contentType:( NSString* )content_type_;

+(id)connectionWithURL:( NSURL* )url_
              postData:( NSData* )data_
               headers:( NSDictionary* )headers_;

-(void)start;
-(void)cancel;

@end
