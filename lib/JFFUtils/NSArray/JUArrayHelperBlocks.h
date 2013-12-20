#ifndef __JU_ARRAY_HELPER_BLOCKS_H__
#define __JU_ARRAY_HELPER_BLOCKS_H__

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void (^JFFActionBlock)( id object_ );
typedef id (^JFFMappingBlock)( id object_ );
typedef id (^JFFMappingWithErrorBlock)( id object_, NSError** outError_ );
typedef void (^JFFMappingDictBlock)( id object_, id* key_, id* value_ );
typedef id (^JFFProducerBlock)( NSUInteger index_ );
typedef NSArray* (^JFFFlattenBlock)( id object_ );

typedef void (^JFFTransformBlock)( id first_object_, id second_object_ );
typedef BOOL (^JFFEqualityCheckerBlock)( id first_object_, id second_object_ );

#endif //__JU_ARRAY_HELPER_BLOCKS_H__
