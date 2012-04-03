#import <Foundation/Foundation.h>

@protocol JFFCacheDB;

@interface JFFCaches : NSObject

@property ( nonatomic, strong, readonly ) NSDictionary* cacheDbByName;

+(JFFCaches*)sharedCaches;

-(id< JFFCacheDB >)cacheByName:( NSString* )name_;

-(id< JFFCacheDB >)thumbnailDB;

@end
