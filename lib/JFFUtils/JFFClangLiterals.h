#import <Foundation/Foundation.h>

@interface NSArray (JFFClangLiterals)

- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end

@interface NSMutableArray (JFFClangLiterals)

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;

@end

@interface NSDictionary (JFFClangLiterals)

- (id)objectForKeyedSubscript:(id)key;

@end

@interface NSMutableDictionary (JFFClangLiterals)

- (void)setObject:(id)newValue forKeyedSubscript:(id)key;

@end
