#import "NSObject+OnDeallocBlock.h"

#import "NSObject+Ownerships.h"
#import "JFFOnDeallocBlockOwner.h"

@interface NSObject (OnDeallocBlockPrivate)

-(BOOL)removeOnDeallocBlockBlock:( void(^)( void ) )block_ fromArray:( NSMutableArray* )array_;

@end

@implementation NSObject (OnDeallocBlockPrivate)

-(BOOL)removeOnDeallocBlockBlock:( void(^)( void ) )block_ fromArray:( NSMutableArray* )array_
{
   return NO;
}

@end

@implementation JFFOnDeallocBlockOwner (OnDeallocBlockPrivate)

-(BOOL)removeOnDeallocBlockBlock:( void(^)( void ) )block_ fromArray:( NSMutableArray* )array_
{
   if ( self.block == block_ )
   {
      self.block = nil;
      [ array_ removeObject: self ];
      return YES;
   }
   return NO;
}

@end

@implementation NSObject (OnDeallocBlock)

-(void)addOnDeallocBlock:( void(^)( void ) )block_
{
   JFFOnDeallocBlockOwner* owner_ = [ [ JFFOnDeallocBlockOwner alloc ] initWithBlock: block_ ];
   [ self.ownerships addObject: owner_ ];
}

-(void)removeOnDeallocBlock:( void(^)( void ) )block_
{
   NSArray* ownerships_ = [ [ NSArray alloc ] initWithArray: self.ownerships ];
   for ( id object_ in ownerships_ )
   {
      if ( [ object_ removeOnDeallocBlockBlock: block_ fromArray: self.ownerships ] )
         break;
   }
}

@end
