#import <Foundation/Foundation.h>

@interface NSObject (DelegateProxy)

- (void)addDelegateProxy:(id)proxy
            delegateName:(NSString *)delegateName;

- (void)removeDelegateProxy:(id)proxy
               delegateName:(NSString *)delegateName;

@end
