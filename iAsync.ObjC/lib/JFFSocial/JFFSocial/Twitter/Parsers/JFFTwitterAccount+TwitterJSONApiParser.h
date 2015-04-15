#import "JFFTwitterAccount.h"

@interface JFFTwitterAccount (TwitterJSONApiParser)

+ (instancetype)newTwitterAccountWithTwitterJSONApiDictionary:(NSDictionary *)dict
                                                        error:(NSError **)error;

@end
