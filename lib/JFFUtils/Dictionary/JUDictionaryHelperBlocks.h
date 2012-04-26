#ifndef __JU_DICTIONARY_HELPER_BLOCKS_H__
#define __JU_DICTIONARY_HELPER_BLOCKS_H__

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef id (^JFFDictMappingBlock)( id key_, id object_ );
typedef BOOL (^JFFDictPredicateBlock)( id key_, id object_ );
typedef void (^JFFDictActionBlock)( id key_, id object_ );

#endif //__JU_DICTIONARY_HELPER_BLOCKS_H__

