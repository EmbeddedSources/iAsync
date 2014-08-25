#import "JNGzipDecoder.h"

#import "JNGzipErrorsLogger.h"
#import "JNGzipCustomErrors.h"

NSString* kGzipErrorDomain = @"gzip.error";

@implementation JNGzipDecoder
{
    z_stream _strm;
    BOOL _isOpen;
    BOOL _done;
    
    unsigned long long _contentLength;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithContentLength:(unsigned long long)contentLength
{
    self = [super init];
    if (nil == self) {
        return nil;
    }
    
    _contentLength = contentLength;
    
    return self;
}

- (BOOL)openZipStreamWithError:(NSError **)outError
{
    if (_isOpen) {
        
        return YES;
    }
    
    _strm.total_out = 0;
    _strm.zalloc    = Z_NULL;
    _strm.zfree     = Z_NULL;
    
    //!! dodikk -- WTF Magic
    int initResult = inflateInit2(&_strm, (15+32));
    BOOL result = (Z_OK == initResult);
    
    if (!result) {
        
        [[JLogger sharedJLogger] logError:@"JNGzipDecoder -- inflateInit2 failed"];
        NSError *gzipError = [NSError errorWithDomain:kGzipErrorDomain
                                                 code:kJNGzipInitFailed
                                             userInfo:nil];
        [gzipError setToPointer:outError];
        
        return NO;
    }

    return YES;
}

//http://www.cocoadev.com/index.pl?NSDataCategory
- (NSData *)decodeData:(NSData *)encodedData
                 error:(NSError **)outError
{
    NSParameterAssert(outError);
    *outError = nil;
    
    if (0 == [encodedData length]) {
        return encodedData;
    }
    
    NSUInteger fullLength = [encodedData length];
    
    static const NSUInteger SCALE_TO_GET_ENOUGH_MEMORY = 3;
    NSUInteger bufferLength_ = SCALE_TO_GET_ENOUGH_MEMORY * fullLength;
    
    NSMutableData* decompressed = [NSMutableData dataWithLength:bufferLength_];
    int  status = 0 ;
    
    _strm.next_in   = (Bytef*)[ encodedData bytes  ];
    _strm.avail_in  = (uInt  )[ encodedData length ];
    
    _isOpen = [ self openZipStreamWithError: outError ];
    if (!_isOpen) {
        return nil;
    }
    else if (_done) {
        [self closeZipStreamWithError:outError];
    }
    
    NSUInteger decompressedThisTime = 0;
    uLong oldTotalOut = _strm.total_out;
    uLong totalCountDiff = 0;
    
    while (0 != _strm.avail_in) {
        
        // Make sure we have enough room and reset the lengths.
        NSUInteger decompressedDataLength = [decompressed length];
        
        if (_strm.total_out >= decompressedDataLength) {
            [ decompressed increaseLengthBy: decompressedDataLength ];
        }
        
        _strm.next_out = [decompressed mutableBytes]  + decompressedThisTime;
        _strm.avail_out = (uInt)( [decompressed length] - decompressedThisTime );
        
        // Inflate another chunk.
        status = inflate (&_strm, Z_SYNC_FLUSH);
        
        totalCountDiff = _strm.total_out - oldTotalOut;
        oldTotalOut = _strm.total_out;
        decompressedThisTime += totalCountDiff;
        
        if (status == Z_STREAM_END)  {
            
            _done = YES;
            break;
        }
        else if (status != Z_OK) {
            
            NSLog(@"[!!! WARNING !!!] JNZipDecoder -- unzip action has failed.\n Zip error code -- %d\n Zip error -- %@",
                  status,
                  [JNGzipErrorsLogger zipErrorMessageFromCode:status]);
            
            
            NSError *gzipError = [NSError errorWithDomain:kGzipErrorDomain
                                                     code:status
                                                 userInfo:nil];
            [gzipError setToPointer:outError];
            
            inflateEnd(&_strm);
            
            return nil;
        }
    }
    
    BOOL isEndingSignatureAvailable = (_strm.avail_in > 0);
    
    if (_done) {
        
        if ( isEndingSignatureAvailable ) {
            
            [self closeZipStreamWithError:outError];
        }
    }
    
    // Set real length.
    [decompressed setLength:decompressedThisTime];
    return [[NSData alloc] initWithData:decompressed];
}

- (BOOL)closeWithError:(NSError **)outError
{
    return [self closeZipStreamWithError:outError];
}

- (BOOL)closeZipStreamWithError:(NSError **)outError
{
    if (!_isOpen) {
        return YES;
    }
    
    int inflateEndResultCode = inflateEnd(&_strm);
    _isOpen = NO;
    
    if (inflateEndResultCode != Z_OK) {
        NSLog( @"[!!! WARNING !!!] JNZipDecoder -- unexpected EOF" );
        
        NSError *gzipError =
        [[NSError alloc] initWithDomain:kGzipErrorDomain
                                   code:kJNGzipUnexpectedEOF
                               userInfo:nil];
        
        [gzipError setToPointer:outError];
        
        return NO;
    }
    
    return YES;
}

@end
