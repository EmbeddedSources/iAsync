#ifndef __JU_ARRAY_HELPER_BLOCKS_H__
#define __JU_ARRAY_HELPER_BLOCKS_H__

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void (^ActionBlock)( id object_ );
typedef id (^MappingBlock)( id object_ );
typedef id (^ProducerBlock)( NSUInteger index_ );
typedef NSArray* (^FlattenBlock)( id object_ );

typedef void (^TransformBlock)( id first_object_, id second_object_ );
typedef BOOL (^EqualityCheckerBlock)( id first_object_, id second_object_ );

#endif //__JU_ARRAY_HELPER_BLOCKS_H__

