#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

JFFAsyncOperation codeURLLoader(NSString *redirectURI,
                                NSString *clientId
                                );

JFFAsyncOperation authedUserDataLoader(NSString *redirectURI,
                                       NSString *clientId,
                                       NSString *clientSecret,
                                       NSString *code
                                       );

JFFAsyncOperation userDataLoader(NSString *userID,
                                 NSString *accessToken
                                 );

JFFAsyncOperation followersJSONDataLoader(NSString *userID,
                                          NSString *accessToken
                                          );

JFFAsyncOperation mediaItemsDataLoader(NSString *userID,
                                       NSString *accessToken
                                       );

JFFAsyncOperation commentMediaItemDataLoader(NSString *mediaItemId,
                                             NSString *comment,
                                             NSString *accessToken);
