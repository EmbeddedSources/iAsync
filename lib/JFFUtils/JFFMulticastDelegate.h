#import <Foundation/Foundation.h>

@interface JFFMulticastDelegate : NSObject

-(void)addDelegate:( id )delegate_;
-(void)removeDelegate:( id )delegate_;
-(void)removeAllDelegates;

@end
