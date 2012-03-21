#import "JFFDownloadItem.h"

#import "JFFFileManager.h"
#import "JFFURLConnection.h"
#import "NSMutableSet+DownloadManager.h"
#import "JFFDownloadItemDelegate.h"
#import "JFFURLResponse.h"

#import "JFFTrafficCalculator.h"
#import "JFFTrafficCalculatorDelegate.h"
#import "NSMutableDictionary+DownloadingFileInfo.h"

#import <JFFLibrary/JFFCompatibility.h>
#import <JFFUtils/JFFMutableAssignArray.h>
#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>
#import <JFFUtils/JFFMulticastDelegate.h>
#import <JFFUtils/JFFError.h>

#import <JFFAsyncOperations/CachedAsyncOperations/NSObject+AsyncPropertyReader.h>
#import <JFFAsyncOperations/JFFAsyncOperationContinuity.h>
#import <JFFAsyncOperations/JFFAsyncOperationHelpers.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>

static JFFMutableAssignArray* download_items_ = nil;

long long JFFUnknownFileLength = NSURLResponseUnknownLength;

@interface JFFDownloadItem () < JFFTrafficCalculatorDelegate >

@property ( nonatomic, retain ) NSURL* url;
@property ( nonatomic, retain ) NSString* localFilePath;

//JTODO MOVE to ARC and remove inner properties
@property ( nonatomic, retain ) JFFTrafficCalculator* trafficCalculator;
@property ( nonatomic, assign ) FILE* file;
@property ( nonatomic, assign ) float previousProgress;
@property ( nonatomic, assign ) float downlodingSpeed;
@property ( nonatomic, assign ) unsigned long long fileLength;
@property ( nonatomic, assign ) unsigned long long downloadedFileLength;

@property ( nonatomic, retain ) NSNull* downloadedFlag;
@property ( nonatomic, copy ) JFFCancelAsyncOperation stopBlock;
@property ( nonatomic, retain ) JFFMulticastDelegate< JFFDownloadItemDelegate >* multicastDelegate;

@end

@implementation JFFDownloadItem

@synthesize url = _url;
@synthesize localFilePath = _local_file_path;
@synthesize stopBlock = _stop_block;
@synthesize trafficCalculator = _traffic_calculator;
@synthesize file = _file;
@synthesize previousProgress = _previous_progress;
@synthesize downlodingSpeed = _downloding_speed;
@synthesize multicastDelegate = _multicast_delegate;

@synthesize downloadedFileLength = _downloaded_file_length;
@synthesize fileLength = _file_length;

@dynamic downloadedFlag;
@dynamic downloaded;
@dynamic activeDownload;

-(void)dealloc
{
   [ self closeFile ];

   [ _url release ];
   [ _local_file_path release ];
   [ _stop_block release ];
   [ _traffic_calculator release ];
   [ _multicast_delegate release ];

   [ super dealloc ];
}

-(unsigned long long)fileSizeForURL:( NSURL* )url_
{
   NSDictionary* dict_ = [ [ NSFileManager defaultManager ] attributesOfItemAtPath: self.localFilePath error: nil ];
   return [ dict_ fileSize ];
}

-(id)initWithURL:( NSURL* )url_
   localFilePath:( NSString* )local_file_path_
{
   self = [ super init ];

   if ( self )
   {
      self.url = url_;
      self.localFilePath = local_file_path_;
      self.downloadedFileLength = [ self fileSizeForURL: url_ ];
      self.multicastDelegate = (JFFMulticastDelegate< JFFDownloadItemDelegate >*)[ [ JFFMulticastDelegate new ] autorelease ];

      if ( self.downloaded )
      {
         self.fileLength = self.downloadedFileLength;
      }
      else
      {
         self.fileLength = [ NSMutableDictionary fileLengthForDestinationURL: url_ ];
      }
   }

   return self;
}

-(JFFTrafficCalculator*)trafficCalculator
{
   if ( !_traffic_calculator )
   {
      _traffic_calculator = [ [ JFFTrafficCalculator alloc ] initWithDelegate: self ];
   }
   return _traffic_calculator;
}

-(void)closeFile
{
   if ( self.file )
   {
      fclose( self.file );
      self.file = 0;
   }
}

-(NSNull*)downloadedFlag
{
   BOOL downloded_ = [ NSMutableSet containsDownloadedFileWithPath: self.localFilePath ];
   return downloded_ ? [ NSNull null ] : nil;
}

-(void)setDownloadedFlag:( NSNull* )downloaded_flag_
{
   if ( downloaded_flag_ )
      [ NSMutableSet addDownloadedFileWithPath: self.localFilePath ];
}

-(float)progress
{
   return ( self.fileLength == NSURLResponseUnknownLength ) ? 0.f : (float) self.downloadedFileLength / self.fileLength;
}

+(BOOL)checkNotAlreadyUsedLocalPath:( NSString* )local_file_path_
                                url:( NSURL* )url_
                              error:( NSError** )outError_
{
    BOOL result_ = [ download_items_.array firstMatch: ^BOOL( id object_ )
    {
        JFFDownloadItem* item_ = object_;
        return ![ item_.url isEqual: url_ ]
            && [ item_.localFilePath isEqualToString: local_file_path_ ];
    } ] == nil;

    if ( !result_ && outError_ )
    {
        static NSString* const errorDescription_ = @"Invalid arguments. This \"local path\" used for another url";
        *outError_ = [ JFFError errorWithDescription: errorDescription_ ];
    }

    return result_;
}

+(id)downloadItemWithURL:( NSURL* )url_
           localFilePath:( NSString* )local_file_path_
                   error:( NSError** )error_
{
    if ( ![ self checkNotAlreadyUsedLocalPath: local_file_path_ url: url_ error: error_ ] )
        return nil;

    id result_ = [ download_items_.array firstMatch: ^BOOL( id object_ )
    {
        JFFDownloadItem* item_ = object_;
        return [ item_.url isEqual: url_ ]
            && [ item_.localFilePath isEqualToString: local_file_path_ ];
    } ];

    if ( !result_ )
    {
        result_ = [ [ [ self alloc ] initWithURL: url_ localFilePath: local_file_path_ ] autorelease ];
        if ( !download_items_ )
        {
            download_items_ = [ JFFMutableAssignArray new ];
        }
        [ download_items_ addObject: result_ ];
    }

    return result_;
}

-(BOOL)downloaded
{
    return self.downloadedFlag != nil;
}

-(BOOL)activeDownload
{
    return self.stopBlock != nil;
}

-(void)start
{
    if ( !self.stopBlock )
        [ self fileLoader ]( nil, nil, nil );
}

-(void)stop
{
    if ( self.stopBlock )
    {
        JFFCancelAsyncOperation stop_block_ = [ self.stopBlock copy ];
        self.stopBlock = nil;
        stop_block_( YES );
        [ stop_block_ release ];
    }
}

-(void)removeDownload
{
    [ self stop ];
    [ NSMutableSet removeDownloadedFileWithPath: self.localFilePath ];
}

+(BOOL)removeDownloadForURL:( NSURL* )url_
              localFilePath:( NSString* )local_file_path_
                      error:( NSError** )error_
{ //http://cocoawithlove.com/2010/07/tips-tricks-for-conditional-ios3-ios32.html
    AUTORELEASE_POOL_BEGIN
    {
        JFFDownloadItem* item_ = [ self downloadItemWithURL: url_ localFilePath: local_file_path_ error: error_ ];
        [ item_ removeDownload ];
        return item_ != nil;
    }
    AUTORELEASE_POOL_END
   
    return NO;
}

-(void)addDelegate:( id< JFFDownloadItemDelegate > )delegate_
{
    [ self.multicastDelegate addDelegate: delegate_ ];
}

-(void)removeDelegate:( id< JFFDownloadItemDelegate > )delegate_
{
    [ self.multicastDelegate removeDelegate: delegate_ ];
}

#pragma mark JFFURLConnection callbacks

-(void)finalizeLoading
{
    self.stopBlock = nil;
    [ self closeFile ];
    [ self.trafficCalculator stop ];
}

-(void)notifyFinishWithError:( NSError* )error_
{
    if ( error_ )
        [ self.multicastDelegate didFailLoadingOfDownloadItem: self error: error_ ];
    else
        [ self.multicastDelegate didFinishLoadingOfDownloadItem: self ];
}

-(void)didFinishLoadedWithError:( NSError* )error_
{
    id downloaded_flag_ = error_ ? nil : [ NSNull null ];
    self.downloadedFlag = downloaded_flag_;

    [ self finalizeLoading ];
}

-(void)didCancelWithFlag:( BOOL )canceled_
          cancelCallback:( JFFCancelAsyncOperationHandler )cancel_callback_
{
    NSParameterAssert( canceled_ );
    [ self finalizeLoading ];

    [ self.multicastDelegate didCancelLoadingOfDownloadItem: self ];

    if ( cancel_callback_ )
        cancel_callback_( canceled_ );
}

-(void)didReceiveData:( NSData* )data_
      progressHandler:( JFFAsyncOperationProgressHandler )progress_callback_
{
    if ( !_traffic_calculator )
        [ self.trafficCalculator startLoading ];

    if ( !self.file )
        self.file = [ JFFFileManager createFileForPath: self.localFilePath ];

    fwrite( [ data_ bytes ], 1, [ data_ length ], self.file );
    fflush( self.file );

    [ self.trafficCalculator bytesReceived: data_.length ];

    self.downloadedFileLength += data_.length;

    if ( ( self.progress - self.previousProgress ) > 0.005f )
    {
        self.previousProgress = self.progress;
        [ self.multicastDelegate didProgressChangeForDownloadItem: self ];
    }

    if ( progress_callback_ )
        progress_callback_( self );
}

-(void)didReceiveResponse:( JFFURLResponse* )response_
{
    self.fileLength = self.downloadedFileLength + response_.expectedContentLength;
}

-(JFFAsyncOperation)fileLoader
{
    JFFAsyncOperation loader_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                         , JFFCancelAsyncOperationHandler cancel_callback_
                                                         , JFFDidFinishAsyncOperationHandler done_callback_ )
    {
        NSString* range_ = [ NSString stringWithFormat: @"bytes=%qu-", self.downloadedFileLength ];
        NSDictionary* headers_ = [ NSDictionary dictionaryWithObject: range_ forKey: @"Range" ];

        JFFURLConnection* connection_ = [ JFFURLConnection connectionWithURL: self.url
                                                                    postData: nil
                                                                     headers: headers_ ];

        progress_callback_ = [ [ progress_callback_ copy ] autorelease ];
        connection_.didReceiveDataBlock = ^( NSData* data_ )
        {
            [ self didReceiveData: data_ 
                  progressHandler: progress_callback_ ];
        };

        done_callback_ = [ [ done_callback_ copy ] autorelease ];
        connection_.didFinishLoadingBlock = ^( NSError* error_ )
        {
            [ self didFinishLoadedWithError: error_ ];

            if ( done_callback_ )
                done_callback_( error_ ? nil : [ NSNull null ], error_ );
        };

        connection_.didReceiveResponseBlock = ^( id/*< JNUrlResponse >*/ response_ )
        {
            [ self didReceiveResponse: response_ ];
        };

        JFFCancelAyncOperationBlockHolder* cancelCallbackBlockHolder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];
        cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
        cancel_callback_ = ^( BOOL canceled_ )
        {
            [ self didCancelWithFlag: canceled_ cancelCallback: cancel_callback_ ];
        };
        cancelCallbackBlockHolder_.cancelBlock = cancel_callback_;

        [ connection_ start ];

        [ self.multicastDelegate didProgressChangeForDownloadItem: self ];

        self.stopBlock = ^void( BOOL canceled_ )
        {
            if ( canceled_ )
                [ connection_ cancel ];
            else
                NSAssert( NO, @"pass canceled_ as YES only" );

            cancelCallbackBlockHolder_.onceCancelBlock( canceled_ );
        };
        return self.stopBlock;
    };

    loader_ = [ self asyncOperationForPropertyWithName: @"downloadedFlag"
                                        asyncOperation: loader_ ];

    JFFDidFinishAsyncOperationHandler did_finish_operation_ = ^void( id result_, NSError* error_ )
    {
        [ self notifyFinishWithError: error_ ];
    };
    return asyncOperationWithFinishCallbackBlock( loader_
                                                 , did_finish_operation_ );
}

#pragma mark JFFTrafficCalculatorDelegate

-(void)trafficCalculator:( JFFTrafficCalculator* )traffic_calculator_
  didChangeDownloadSpeed:( float )speed_
{
    self.downlodingSpeed = speed_;
    [ self.multicastDelegate didProgressChangeForDownloadItem: self ];
}

@end
