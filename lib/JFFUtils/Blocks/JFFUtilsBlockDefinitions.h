#ifndef JFF_UTILS_BLOCK_DEFINITIONS
#define JFF_UTILS_BLOCK_DEFINITIONS

#include <objc/objc.h>

@class NSError;

typedef void (^JFFSimpleBlock)( void );
typedef BOOL (^JFFPredicateBlock)( id object_ );
typedef id (^JFFAnalyzer)(id result_, NSError** error_);

#endif //JFF_UTILS_BLOCK_DEFINITIONS
