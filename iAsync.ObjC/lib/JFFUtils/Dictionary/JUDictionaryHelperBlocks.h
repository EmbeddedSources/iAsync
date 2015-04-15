#ifndef __JU_DICTIONARY_HELPER_BLOCKS_H__
#define __JU_DICTIONARY_HELPER_BLOCKS_H__

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef id (^JFFDictMappingBlock)(id key, id object);
typedef id (^JFFDictMappingWithErrorBlock)(id key, id object, NSError *__autoreleasing *outError);
typedef BOOL (^JFFDictPredicateBlock)(id key, id object);
typedef void (^JFFDictActionBlock)(id key, id object);

#endif //__JU_DICTIONARY_HELPER_BLOCKS_H__

