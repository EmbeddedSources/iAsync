//
//  NSError+CanceledPurchase.m
//  JFFStoreKit
//
//  Created by Vladimir Gorbenko on 22.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

#import "NSError+CanceledPurchase.h"

@implementation NSError (CanceledPurchase)

- (BOOL)isCanceledPurchaseAuthorization
{
    BOOL result = [@"SSErrorDomain" isEqualToString:self.domain] && self.code == 16;
    
    return result;
}

@end
