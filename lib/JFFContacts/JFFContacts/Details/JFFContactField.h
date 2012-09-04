#import <AddressBook/AddressBook.h>

#import <Foundation/Foundation.h>

@interface JFFContactField : NSObject

@property ( nonatomic, readonly ) NSString* name;
@property ( nonatomic, readonly ) ABPropertyID propertyID;

@property ( nonatomic, strong ) id value;

+(id)contactFieldWithName:( NSString* )name_
               propertyID:( ABPropertyID )propertyID_;

-(void)readPropertyFromRecord:( ABRecordRef )record_;
-(void)setPropertyFromValue:( id )value_
                   toRecord:( ABRecordRef )record_;

@end
