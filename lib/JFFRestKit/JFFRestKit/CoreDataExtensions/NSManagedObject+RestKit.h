#import <CoreData/CoreData.h>

@interface NSManagedObject (RestKit)

+(id)newManagedObject;
+(id)firstManagedObjectWithPredicate:( NSPredicate* )predicate_;

+(void)setSharedManagedObjectContext:( NSManagedObjectContext* )context_;
+(id)sharedManagedObjectContext;

@end
