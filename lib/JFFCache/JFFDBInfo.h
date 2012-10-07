#import <Foundation/Foundation.h>

@interface JFFDBInfo : NSObject

@property (atomic, readonly) NSDictionary *dbInfo;
@property (atomic) NSDictionary *currentDbInfo;

- (id)initWithInfoPath:(NSString *)infoPath;
- (id)initWithInfoDictionary:(NSDictionary *)infoDictionry;

+ (void)setSharedDBInfo:(JFFDBInfo *)dbInfo;
+ (JFFDBInfo*)sharedDBInfo;

@end
