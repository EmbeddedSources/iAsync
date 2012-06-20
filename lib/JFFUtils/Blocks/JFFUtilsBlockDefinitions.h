#ifndef JFF_UTILS_BLOCK_DEFINITIONS
#define JFF_UTILS_BLOCK_DEFINITIONS

#import <Foundation/Foundation.h>

typedef void (^JFFSimpleBlock)( void );
typedef BOOL (^JFFPredicateBlock)( id object_ );
typedef BOOL (^JFFPredicateWithIndexBlock)( id object_, NSUInteger index_ );
typedef id (^JFFAnalyzer)( id result_, NSError** error_ );

#endif //JFF_UTILS_BLOCK_DEFINITIONS
