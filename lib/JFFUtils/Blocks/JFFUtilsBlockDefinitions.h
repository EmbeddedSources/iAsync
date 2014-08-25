#ifndef JFF_UTILS_BLOCK_DEFINITIONS
#define JFF_UTILS_BLOCK_DEFINITIONS

#import <Foundation/Foundation.h>

typedef void (^JFFSimpleBlock)(void);
typedef BOOL (^JFFPredicateBlock)(id object);
typedef BOOL (^JFFPredicateWithIndexBlock)(id object, NSInteger index);
typedef id (^JFFAnalyzer)(id result, NSError **outError);

#endif //JFF_UTILS_BLOCK_DEFINITIONS
