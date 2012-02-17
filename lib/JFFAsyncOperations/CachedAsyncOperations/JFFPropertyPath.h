#import <Foundation/Foundation.h>

@interface JFFPropertyPath : NSObject

@property ( nonatomic, strong, readonly ) NSString* name;
@property ( nonatomic, strong, readonly ) id< NSCopying, NSObject > key;

-(id)initWithName:( NSString* )name_
              key:( id< NSCopying, NSObject > )key_;

@end
