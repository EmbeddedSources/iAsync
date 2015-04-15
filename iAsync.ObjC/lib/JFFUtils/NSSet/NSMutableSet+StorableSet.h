#import <Foundation/Foundation.h>

@interface NSMutableSet (StorableSet)

+ (instancetype)newStorableSetWithContentsOfFile:(NSString *)fileName;

- (BOOL)addAndSaveObject:(id)object
                fileName:(NSString *)fileName;

- (BOOL)removeAndSaveObject:(id)object
                   fileName:(NSString *)fileName;

- (BOOL)saveDataWithFileName:(NSString *)fileName;

@end
