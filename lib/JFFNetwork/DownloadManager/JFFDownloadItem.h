#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFDownloadItemDelegate;

extern long long JFFUnknownFileLength;

@interface JFFDownloadItem : NSObject

@property ( nonatomic, readonly ) NSURL* url;
@property ( nonatomic, readonly ) NSString* localFilePath;

@property ( nonatomic, readonly ) unsigned long long fileLength;
@property ( nonatomic, readonly ) unsigned long long downloadedFileLength;
@property ( nonatomic, readonly ) BOOL downloaded;
@property ( nonatomic, readonly ) float progress;
@property ( nonatomic, readonly ) BOOL activeDownload;
@property ( nonatomic, readonly ) float downlodingSpeed;

//can return existing download item
+(id)downloadItemWithURL:( NSURL* )url_
           localFilePath:( NSString* )localFilePath_
                   error:( NSError** )error_;

+(BOOL)removeDownloadForURL:( NSURL* )url_
              localFilePath:( NSString* )localFilePath_
                      error:( NSError** )error_;

-(void)start;
-(void)stop;
-(void)removeDownload;

-(void)addDelegate:( id< JFFDownloadItemDelegate > )delegate_;
-(void)removeDelegate:( id< JFFDownloadItemDelegate > )delegate_;

-(JFFAsyncOperation)fileLoader;

@end
