#import <JFFUtils/Dictionary/JUDictionaryHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface JFFMutableAssignDictionary : NSObject

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;
- (NSDictionary *)map:(JFFDictMappingBlock)block;

- (NSUInteger)count;

- (id)objectForKey:(id)key;
- (id)objectForKeyedSubscript:(id)key;

- (void)removeObjectForKey:(id)key;

- (void)setObject:(id)object forKey:(id)key;
- (void)setObject:(id)newValue forKeyedSubscript:(id)key;

- (void)removeAllObjects;

@end
