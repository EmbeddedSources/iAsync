#import <JFFStoreKit/Errors/JFFStoreKitError.h>

@interface JFFStoreKitCanNoLoadProductError : JFFStoreKitError

@property (nonatomic) NSString *productIdentifier;

@end
