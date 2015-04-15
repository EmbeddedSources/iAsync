#import <Foundation/Foundation.h>

@interface NSObject (JFFJsonObjectValidator)

- (BOOL)validateWithJsonPatternValue:(id)jsonPattern
                      rootJsonObject:(id)rootJsonObject
                     rootJsonPattern:(id)rootJsonPattern
                               error:(NSError *__autoreleasing *)outError;

- (BOOL)validateWithJsonPatternClass:(id)jsonPattern
                      rootJsonObject:(id)rootJsonObject
                     rootJsonPattern:(id)rootJsonPattern
                               error:(NSError *__autoreleasing *)outError;

- (BOOL)validateWithJsonPattern:(id)jsonPattern
                 rootJsonObject:(id)rootJsonObject
                rootJsonPattern:(id)rootJsonPattern
                          error:(NSError *__autoreleasing *)outError;

@end
