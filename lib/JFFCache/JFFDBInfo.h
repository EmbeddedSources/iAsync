#import <Foundation/Foundation.h>

@interface NSDictionary (DBInfo)

-(NSTimeInterval)timeToLiveForDBWithName:( NSString* )name_;
-(NSTimeInterval)autoRemoveByLastAccessDateForDBWithName:( NSString* )name_;

-(NSString*)fileNameForDBWithName:( NSString* )name_;
-(NSUInteger)versionForDBWithName:( NSString* )name_;
-(BOOL)hasExpirationDateDBWithName:( NSString* )name_;

@end

@interface JFFDBInfo : NSObject

@property ( nonatomic, strong, readonly ) NSDictionary* dbInfo;
@property ( nonatomic, strong ) NSDictionary* currentDbInfo;

-(id)initWithInfoPath:( NSString* )infoPath_;
-(id)initWithInfoDictionary:( NSDictionary* )infoDictionry_;

+(void)setSharedDBInfo:( JFFDBInfo* )dbInfo_;
+(JFFDBInfo*)sharedDBInfo;

@end
