#import <Foundation/Foundation.h>

@class JFFDownloadItem;

@protocol JFFDownloadItemDelegate <NSObject>

@optional
-(void)didProgressChangeForDownloadItem:( JFFDownloadItem* )download_item_;

-(void)didFailLoadingOfDownloadItem:( JFFDownloadItem* )download_item_ error:( NSError* )error_;

-(void)didFinishLoadingOfDownloadItem:( JFFDownloadItem* )download_item_;

-(void)didCancelLoadingOfDownloadItem:( JFFDownloadItem* )download_item_;

@end
