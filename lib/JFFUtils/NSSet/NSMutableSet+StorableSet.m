#import "NSMutableSet+StorableSet.h"

#import "NSString+PathExtensions.h"
#import "NSString+FileAttributes.h"

#include <objc/runtime.h>

static char propertyKey;

@implementation NSMutableSet (StorableSet)

- (void)setStoreFilePath:(NSString *)path
{
    objc_setAssociatedObject(self, &propertyKey, path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)storeFilePath
{
    NSString *result = objc_getAssociatedObject(self, &propertyKey);
    
    return result;
}

+ (id)newStorableSetWithContentsOfFile:(NSString *)fileName
{
    NSParameterAssert(fileName);
    
    fileName = [NSString documentsPathByAppendingPathComponent:fileName];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:fileName];
    NSMutableSet *result = [[NSMutableSet alloc] initWithArray:array];
    result.storeFilePath = fileName;
    return result;
}

- (BOOL)addAndSaveObject:(id)object
{
    [self addObject:object];
    
    return [self saveData];
}

- (BOOL)removeAndSaveObject:(id)object
{
    [self removeObject:object];
    
    return [self saveData];
}

- (BOOL)saveData
{
    NSArray *array = [self allObjects];
    
    NSString *storeFilePath = self.storeFilePath;
    BOOL result = [array writeToFile:storeFilePath atomically:YES];
    [storeFilePath addSkipBackupAttribute];
    return result;
}

@end
