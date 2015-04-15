#import <Foundation/Foundation.h>

@interface JFFNetworkResponseDataCallback : NSObject

@property (nonatomic) NSData *dataChunk;

@property (nonatomic) unsigned long long downloadedBytesCount;
@property (nonatomic) unsigned long long totalBytesCount;

@end
