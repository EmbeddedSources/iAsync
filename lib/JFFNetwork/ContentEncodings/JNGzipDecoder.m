#import "JNGzipDecoder.h"

#import "JNGzipErrorsLogger.h"
#import "JNGzipCustomErrors.h"
#import "JNConstants.h"

NSString* kGzipErrorDomain = @"gzip.error";

@implementation JNGzipDecoder
{
    z_stream _strm;
    BOOL _isOpen;
    BOOL _done;
    
    unsigned long long _contentLength;
}

-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(id)initWithContentLength:( unsigned long long )contentLength_
{
    self = [ super init ];
    if ( nil == self )
    {
        return nil;
    }
    
    self->_contentLength = contentLength_;
    
    return self;
}

-(BOOL)openZipStreamWithError:( NSError** )outError
{
    if ( self->_isOpen )
    {
        return YES;
    }

    self->_strm.total_out = 0;
    self->_strm.zalloc    = Z_NULL;
    self->_strm.zfree     = Z_NULL;


    //!! dodikk -- WTF Magic
    int initResult = inflateInit2( &self->_strm, (15+32) );
    BOOL result = ( Z_OK == initResult );

    if ( !result )
    {
        [ JFFLogger logErrorWithFormat:@"JNGzipDecoder -- inflateInit2 failed" ];
        NSError* gzipError = [ NSError errorWithDomain: kGzipErrorDomain
                                                  code: kJNGzipInitFailed
                                              userInfo: nil ];
        [ gzipError setToPointer: outError ];
        
        return NO;
    }

    return YES;
}

//http://www.cocoadev.com/index.pl?NSDataCategory
- (NSData*)decodeData:(NSData *)encodedData_
                error:(NSError **)outError
{
    NSParameterAssert(outError);
    *outError = nil;

    if ( 0 == [ encodedData_ length ] ) 
    {
        return encodedData_;
    }

    NSUInteger full_length_ = [ encodedData_ length ];

    static const NSUInteger SCALE_TO_GET_ENOUGH_MEMORY = 3;
    NSUInteger bufferLength_ = SCALE_TO_GET_ENOUGH_MEMORY * full_length_;
    
    NSMutableData* decompressed_ = [ NSMutableData dataWithLength: bufferLength_ ];
    int  status_ = 0 ;

    self->_strm.next_in   = (Bytef*)[ encodedData_ bytes  ];
    self->_strm.avail_in  = (uInt  )[ encodedData_ length ];
    

    
    self->_isOpen = [ self openZipStreamWithError: outError ];
    if ( !self->_isOpen )
    {
        return nil;
    }
    else if ( self->_done )
    {
        [ self closeZipStreamWithError: outError ];
    }
    
    
    
    NSUInteger decompressedThisTime = 0;
    uLong oldTotalOut = self->_strm.total_out;
    uLong totalCountDiff = 0;
    
    while ( 0 != self->_strm.avail_in )
    {
        // Make sure we have enough room and reset the lengths.
        NSUInteger decompressedDataLength_ = [ decompressed_ length ];
        
        if ( self->_strm.total_out >= decompressedDataLength_)
        {
            [ decompressed_ increaseLengthBy: decompressedDataLength_ ];
        }
        
        self->_strm.next_out = [decompressed_ mutableBytes]  + decompressedThisTime;
        self->_strm.avail_out = (uInt)( [decompressed_ length] - decompressedThisTime );

        // Inflate another chunk.
        status_ = inflate (&self->_strm, Z_SYNC_FLUSH);
        
        
        totalCountDiff = self->_strm.total_out - oldTotalOut;
        oldTotalOut = self->_strm.total_out;
        decompressedThisTime += totalCountDiff;
        
        
        if (status_ == Z_STREAM_END) 
        {
            self->_done = YES;
            break;
        }
        else if (status_ != Z_OK)
        {
            NSLog( @"[!!! WARNING !!!] JNZipDecoder -- unzip action has failed.\n Zip error code -- %d\n Zip error -- %@"
                  , status_
                  , [ JNGzipErrorsLogger zipErrorMessageFromCode: status_ ] );
            
            
            NSError* gzipError = [ NSError errorWithDomain: kGzipErrorDomain
                                                      code: status_
                                                  userInfo: nil ];
            [ gzipError setToPointer: outError ];
            
            inflateEnd(&self->_strm);
            
            return nil;
        }
    }

    
    BOOL isEndingSignatureAvailable = ( self->_strm.avail_in > 0 );
    if ( self->_done )
    {
        if ( isEndingSignatureAvailable )
        {
            [ self closeZipStreamWithError: outError ];
        }
	}

    // Set real length.
        [ decompressed_ setLength: decompressedThisTime ];
        return [ NSData dataWithData: decompressed_ ];
}

-(BOOL)closeWithError:( NSError ** )outError
{
    return [ self closeZipStreamWithError: outError ];
}

-(BOOL)closeZipStreamWithError:( NSError ** )outError
{
    if ( !self->_isOpen )
    {
        return YES;
    }
    
    
    int inflateEndResultCode_ = inflateEnd (&self->_strm);
    self->_isOpen = NO;
    
    if ( inflateEndResultCode_ != Z_OK)
    {
        NSLog( @"[!!! WARNING !!!] JNZipDecoder -- unexpected EOF" );
        
        NSError* gzipError =
        [ NSError errorWithDomain: kGzipErrorDomain
                                         code: kJNGzipUnexpectedEOF
                                     userInfo: nil ];
        
        [ gzipError setToPointer: outError ];
        
        return NO;
    }
    
    return YES;
}

@end
