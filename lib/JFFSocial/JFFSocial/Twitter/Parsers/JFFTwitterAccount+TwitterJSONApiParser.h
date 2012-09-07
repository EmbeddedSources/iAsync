#import "JFFTwitterAccount.h"

@interface JFFTwitterAccount (TwitterJSONApiParser)

+ (id)newTwitterAccountWithTwitterJSONApiDictionary:(NSDictionary *)dict
                                              error:(NSError **)error;

@end
