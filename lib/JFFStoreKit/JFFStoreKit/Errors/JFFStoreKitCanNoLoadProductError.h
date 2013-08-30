#import <JFFStoreKit/Errors/JFFStoreKitError.h>

#import <Foundation/Foundation.h>

@interface JFFStoreKitCanNoLoadProductError : JFFStoreKitError

@property (nonatomic) NSString *productIdentifier;

@end
