#import <Foundation/Foundation.h>

@interface NSObject (Ownerships)

//lazy load property, any object can be added to this array
@property (nonatomic, readonly) NSMutableArray *ownerships;

@end
