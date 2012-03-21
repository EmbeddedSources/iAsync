#import <Foundation/Foundation.h>

@interface NSError (ResultOwnerships)

//lazy load property, any object can be added to this array
@property ( nonatomic, retain ) NSMutableArray* resultOwnerships;

@property ( nonatomic, retain, readonly ) NSMutableArray* lazyResultOwnerships;

@end
