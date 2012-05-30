#import <Foundation/Foundation.h>

@interface NSError (ResultOwnerships)

//lazy load property, any object can be added to this array
@property ( nonatomic, strong ) NSMutableArray* resultOwnerships;

@property ( nonatomic, strong, readonly ) NSMutableArray* lazyResultOwnerships;

@end
