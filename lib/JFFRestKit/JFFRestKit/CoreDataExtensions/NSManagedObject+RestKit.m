#import "NSManagedObject+RestKit.h"

static NSManagedObjectContext* sharedContext_ = nil;

@implementation NSManagedObject (RestKit)

+(id)newManagedObject
{
    return [ NSEntityDescription insertNewObjectForEntityForName: [ self description ]
                                          inManagedObjectContext: sharedContext_ ];
}

+(id)firstManagedObjectWithPredicate:( NSPredicate* )predicate_
{
    NSEntityDescription* entityDescription_ =
        [ NSEntityDescription entityForName: [ self description ]
                     inManagedObjectContext: sharedContext_ ];

    NSFetchRequest* request_ = [ NSFetchRequest new ];
    [ request_ setEntity: entityDescription_ ];

    if ( predicate_ )
        [ request_ setPredicate: predicate_ ];

    NSError* error_ = nil;
    NSArray* array_ = [ sharedContext_ executeFetchRequest: request_ error: &error_ ];
    if ( error_ )
    {
        NSLog( @"RestKit error: %@", error_ );
    }

    return [ array_ noThrowObjectAtIndex: 0 ];
}

+(void)setSharedManagedObjectContext:( NSManagedObjectContext* )context_
{
    sharedContext_ = context_;
}

+(id)sharedManagedObjectContext
{
    return sharedContext_;
}

@end
