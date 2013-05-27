#import "NSMutableSet+StorableSet.h"

#import "NSString+PathExtensions.h"
#import "NSString+FileAttributes.h"

#include "JFFRuntimeAddiotions.h"

@interface NSMutableSet (StorableSet_Internal)

@property (nonatomic) NSString *storeFilePath;

@end

@implementation NSMutableSet (StorableSet_Internal)

@dynamic storeFilePath;

+ (void)load
{
    jClass_implementProperty(self, @"storeFilePath");
}

@end

@implementation NSMutableSet (StorableSet)

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
    if (result)
        [storeFilePath addSkipBackupAttribute];
    return result;
}

@end
