#import "JFFURLConnection.h"
#import "JNAbstractConnection+Constructor.h"

#import "JFFURLResponse.h"

#import "JNHttpDecoder.h"
#import "JNHttpEncodingsFactory.h"
#import "JNConstants.h"

#import <JFFUtils/JFFError.h>

@interface JFFURLConnection ()

//JTODO move to ARC and remove inner properties
@property ( nonatomic, retain ) NSData* postData;
@property ( nonatomic, retain ) NSDictionary* headers;

@property ( nonatomic, assign ) BOOL responseHandled;
@property ( nonatomic, retain ) NSURL* url;

@property ( nonatomic, retain ) JFFURLResponse* urlResponse;

-(void)startConnectionWithPostData:( NSData* )data_
                           headers:( NSDictionary* )headers_;

-(void)cancel;

-(void)closeReadStream;

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_;
-(void)handleData:( void* )buffer_ length:( NSUInteger )length_;
-(void)handleFinish:( NSError* )error_;

@end

static void readStreamCallback( CFReadStreamRef stream_, CFStreamEventType event_, void* self_context_ )
{
    JFFURLConnection* self_ = self_context_;
    switch( event_ )
    {
        case kCFStreamEventHasBytesAvailable:
        {
            [ self_ handleResponseForReadStream: stream_ ];

            UInt8 buffer_[ kJNMaxBufferSize ];
            CFIndex bytes_read_ = CFReadStreamRead( stream_, buffer_, kJNMaxBufferSize );
            if ( bytes_read_ > 0 )
            {
                [ self_ handleData: buffer_
                            length: bytes_read_ ];
            }
            break;
        }
        case kCFStreamEventErrorOccurred:
        {
            [ self_ handleResponseForReadStream: stream_ ];

            CFStreamError error_ = CFReadStreamGetError( stream_ );
            NSString* errorDescription_ = [ NSString stringWithFormat: @"CFStreamError domain: %d", error_.domain ];

            [ self_ handleFinish: [ JFFError errorWithDescription: errorDescription_
                                                             code: error_.error ] ];
            break;
        }
        case kCFStreamEventEndEncountered:
        {
            [ self_ handleResponseForReadStream: stream_ ];

            [ self_ handleFinish: nil ];
            break;
        }
    }
}

@implementation JFFURLConnection

@synthesize postData = _post_data;
@synthesize headers = _headers;

@synthesize url = _url;
@synthesize responseHandled = _response_handled;

@synthesize urlResponse = _url_response;

-(void)dealloc
{
   [ self cancel ];

   [ _post_data    release ];
   [ _headers      release ];
   [ _url          release ];
  
   [ _url_response release ];

   [ super dealloc ];
}

-(id)initWithURL:( NSURL* )url_
        postData:( NSData* )data_
         headers:( NSDictionary* )headers_
{
   self = [ super privateInit ];

   if ( self )
   {
      self.url = url_;
      self.postData = data_;
      self.headers = headers_;
   }

   return self;
}

-(void)start
{
   [ self startConnectionWithPostData: self.postData headers: self.headers ];
}

+(id)connectionWithURL:( NSURL* )url_
              postData:( NSData* )data_
           contentType:( NSString* )content_type_
{
   NSDictionary* headers_ = [ NSDictionary dictionaryWithObjectsAndKeys: 
                                 content_type_, @"Content-Type"
                               , @"keep-alive", @"Connection"
                               , nil 
                            ];

   return [ self connectionWithURL: url_
                          postData: data_
                           headers: headers_ ];
}

+(id)connectionWithURL:( NSURL* )url_
              postData:( NSData* )data_
               headers:( NSDictionary* )headers_
{
   return [ [ [ self alloc ] initWithURL: url_
                                postData: data_
                                 headers: headers_ ] autorelease ];
}

-(void)applyCookiesForHTTPRequest:( CFHTTPMessageRef )httpRequest_
{
    NSArray* availableCookies_ = [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] cookiesForURL: self.url ];

    NSDictionary* headers_ = [ NSHTTPCookie requestHeaderFieldsWithCookies: availableCookies_ ];

    for ( NSString* key_ in headers_ )
    {
        NSString* value_ = [ headers_ objectForKey: key_ ];
        CFHTTPMessageSetHeaderFieldValue ( httpRequest_, (CFStringRef)key_, (CFStringRef)value_ );
    }
}

//JTODO add timeout
//JTODO test invalid url
//JTODO test no internet connection
-(void)startConnectionWithPostData:( NSData* )data_
                           headers:( NSDictionary* )headers_
{
    CFStringRef method_ = (CFStringRef) ( data_ ? @"POST" : @"GET" );
    CFHTTPMessageRef httpRequest_ = CFHTTPMessageCreateRequest( NULL
                                                               , method_
                                                               , (CFURLRef)self.url
                                                               , kCFHTTPVersion1_1 );

    [ self applyCookiesForHTTPRequest: httpRequest_ ];

    if ( data_ )
    {
        CFHTTPMessageSetBody ( httpRequest_, (CFDataRef)data_ );
    }

    for ( NSString* header_ in headers_ )
    {
        CFHTTPMessageSetHeaderFieldValue( httpRequest_
                                         ,(CFStringRef)header_
                                         ,(CFStringRef)[ headers_ objectForKey: header_ ] );
    }

    //   CFReadStreamCreateForStreamedHTTPRequest( CFAllocatorRef alloc,
    //                                             CFHTTPMessageRef requestHeaders,
    //                                             CFReadStreamRef	requestBody )
    _read_stream = CFReadStreamCreateForHTTPRequest( NULL, httpRequest_ );
    CFRelease( httpRequest_ );

    //Prefer using keep-alive packages
    Boolean keep_alive_set_result_ = CFReadStreamSetProperty( _read_stream, kCFStreamPropertyHTTPAttemptPersistentConnection, kCFBooleanTrue );
    if ( FALSE == keep_alive_set_result_ )
    {
        NSLog( @"JFFURLConnection->start : unable to setup keep-alive packages" );
    }

    typedef void* (*retain)( void* info_ );
    typedef void (*release)( void* info_ );
    CFStreamClientContext stream_context_ = { 0, self, (retain)CFRetain, (release)CFRelease, NULL };

    CFOptionFlags registered_events_ = kCFStreamEventHasBytesAvailable
        | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    if ( CFReadStreamSetClient( _read_stream, registered_events_, readStreamCallback, &stream_context_ ) )
    {
        CFReadStreamScheduleWithRunLoop( _read_stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );
    }

    CFReadStreamOpen( _read_stream );
}

-(void)closeReadStream
{
    if ( _read_stream )
    {
        CFReadStreamUnscheduleFromRunLoop( _read_stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );
        CFReadStreamClose( _read_stream );
        CFRelease( _read_stream );
        _read_stream = NULL;
    }
}

-(void)closeStreams
{
    [ self closeReadStream ];
}

-(void)cancel
{
    [ self closeStreams ];
    [ self clearCallbacks ];
}

-(void)handleData:( void* )buffer_ 
           length:( NSUInteger )length_
{
    if ( !self.didReceiveDataBlock )
    {
        return;
    }

    NSString* content_encoding_ = [ self.urlResponse.allHeaderFields objectForKey: @"Content-Encoding" ];
    id< JNHttpDecoder > decoder_ = [ JNHttpEncodingsFactory decoderForHeaderString: content_encoding_ ];

    NSError* decoder_error_ = nil;

    NSData* raw_ns_data_ = [ NSData dataWithBytes: buffer_ 
                                           length: length_ ];

    NSData* decoded_data_ = [ decoder_ decodeData: raw_ns_data_ 
                                            error: &decoder_error_ ];

    if ( nil == decoded_data_ )
    {
        [ self handleFinish: decoder_error_ ];
    }
    else 
    {
        self.didReceiveDataBlock( decoded_data_ );
    }
}

-(void)handleFinish:( NSError* )error_
{
    [ self closeReadStream ];

    if ( self.didFinishLoadingBlock )
    {
        self.didFinishLoadingBlock( error_ );
    }
    [ self clearCallbacks ];
}

-(void)acceptCookiesForHeaders:( NSDictionary* )headers_
{
    NSArray* cookies_ = [ NSHTTPCookie cookiesWithResponseHeaderFields: headers_ forURL: self.url ];
    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] setCookie: cookie_ ];
    }
}

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_
{
    if ( self.responseHandled )
    {
        return;
    }

    CFHTTPMessageRef response_ = (CFHTTPMessageRef)CFReadStreamCopyProperty( stream_, kCFStreamPropertyHTTPResponseHeader );
    if ( response_ )
    {
        self.responseHandled = YES;

        CFDictionaryRef allHeaders_ = CFHTTPMessageCopyAllHeaderFields( response_ );
        [ self acceptCookiesForHeaders: (NSDictionary*)allHeaders_ ];

        if ( self.didReceiveResponseBlock )
        {
            CFIndex error_code_ = CFHTTPMessageGetResponseStatusCode( response_ );

            JFFURLResponse* urlResponse_ = [ JFFURLResponse new ];
            urlResponse_.statusCode = error_code_;

            urlResponse_.allHeaderFields = (NSDictionary*)allHeaders_;

            self.didReceiveResponseBlock( urlResponse_ );
            self.didReceiveResponseBlock = nil;

            self.urlResponse = urlResponse_;
            [ urlResponse_ release ];
        }

        CFRelease( allHeaders_ );
        CFRelease( response_ );
    }
}

@end
