#import "NSMutableSet+StorableSet.h"

#import "NSString+PathExtensions.h"
#import "NSString+FileAttributes.h"

#include "JFFRuntimeAddiotions.h"

@implementation NSMutableSet (StorableSet)

+ (instancetype)newStorableSetWithContentsOfFile:(NSString *)fileName
{
    NSParameterAssert(fileName);
    
    fileName = [NSString documentsPathByAppendingPathComponent:fileName];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:fileName];
    NSMutableSet *result = [[NSMutableSet alloc] initWithArray:array];
    return result;
}

- (BOOL)addAndSaveObject:(id)object
                fileName:(NSString *)fileName
{
    [self addObject:object];
    
    return [self saveDataWithFileName:fileName];
}

- (BOOL)removeAndSaveObject:(id)object
                   fileName:(NSString *)fileName
{
    [self removeObject:object];
    
    return [self saveDataWithFileName:fileName];
}

- (BOOL)saveDataWithFileName:(NSString *)fileName
{
    NSArray *array = [self allObjects];
    
    NSString *storeFilePath = fileName;
    BOOL result = [array writeToFile:storeFilePath atomically:YES];
    if (result) {
        [storeFilePath addSkipBackupAttribute];
    }
    return result;
}

@end
