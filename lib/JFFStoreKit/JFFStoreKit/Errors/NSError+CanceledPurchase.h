//
//  NSError+CanceledPurchase.h
//  JFFStoreKit
//
//  Created by Vladimir Gorbenko on 22.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (CanceledPurchase)

- (BOOL)isCanceledPurchaseAuthorization;

@end
