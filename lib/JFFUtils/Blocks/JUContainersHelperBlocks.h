#ifndef __JU_ARRAY_HELPER_BLOCKS_H__
#define __JU_ARRAY_HELPER_BLOCKS_H__

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void (^JFFActionBlock)(id object);
typedef id (^JFFMappingBlock)(id object);
typedef id (^JFFMappingWithErrorBlock)(id object, NSError **outError);
typedef id (^JFFMappingWithErrorAndIndexBlock)(id object, NSInteger idx, NSError **outError);
typedef void (^JFFMappingDictBlock)(id object,id *key, id *value);
typedef id (^JFFProducerBlock)(NSInteger index);
typedef NSArray* (^JFFFlattenBlock)(id object);

typedef void (^JFFTransformBlock)(id firstObject, id secondObject);
typedef NSInteger (^JFFElementIndexBlock)(id object);
typedef BOOL (^JFFEqualityCheckerBlock)(id firstObject, id secondObject);

#endif //__JU_ARRAY_HELPER_BLOCKS_H__
