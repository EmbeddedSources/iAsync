#import <Foundation/Foundation.h>

@interface NSMutableSet (StorableSet)

+ (id)newStorableSetWithContentsOfFile:(NSString *)fileName;

- (BOOL)addAndSaveObject:(id)object;
- (BOOL)removeAndSaveObject:(id)object;

- (BOOL)saveData;

@end
