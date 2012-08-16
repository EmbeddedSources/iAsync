#import <Foundation/Foundation.h>

@interface NSError (ResultOwnerships)

//lazy load property, any object can be added to this array
@property ( nonatomic ) NSMutableArray* resultOwnerships;

@property ( nonatomic, readonly ) NSMutableArray* lazyResultOwnerships;

@end
