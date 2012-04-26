#import <Foundation/Foundation.h>

@interface JFFDBCompositeKey : NSObject 

+(id)compositeKeyWithKeys:( NSString* )key_, ...;
+(id)compositeKeyWithKey:( JFFDBCompositeKey* )composite_key_ forIndexes:( NSIndexSet* )indexes_;

-(NSString*)toCompositeKey;

@end

