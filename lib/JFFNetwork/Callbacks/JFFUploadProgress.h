#import <Foundation/Foundation.h>

@protocol JFFUploadProgress <NSObject>

-(NSNumber*)progress;
-(NSURL*)url;
-(NSDictionary*)headers;

@end
