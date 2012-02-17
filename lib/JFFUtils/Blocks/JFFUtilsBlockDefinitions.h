#ifndef JFF_UTILS_BLOCK_DEFINITIONS
#define JFF_UTILS_BLOCK_DEFINITIONS

#include <objc/objc.h>

@class NSError;

typedef void (^JFFSimpleBlock)( void );
typedef BOOL (^PredicateBlock)( id object_ );//JTODO rename to JPredicateBlock
typedef id (^JFFAnalyzer)(id result_, NSError** error_);

#endif //JFF_UTILS_BLOCK_DEFINITIONS
