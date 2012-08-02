#import <Foundation/Foundation.h>

@interface NSArray (JFFClangLiterals)

-(id)objectAtIndexedSubscript:( NSUInteger )index_;

@end

@interface NSMutableArray (JFFClangLiterals)

-(void)setObject:( id )anObject_ atIndexedSubscript:( NSUInteger )index_;

@end

@interface NSDictionary (JFFClangLiterals)

-(id)objectForKeyedSubscript:( id )key_;

@end

@interface NSMutableDictionary (JFFClangLiterals)

-(void)setObject:( id )newValue_ forKeyedSubscript:( id )key_;

@end
