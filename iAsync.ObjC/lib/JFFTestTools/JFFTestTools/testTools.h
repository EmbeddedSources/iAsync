#include <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

NSTimeInterval performTimeCalculator(JFFSimpleBlock block, NSUInteger times);

void performAsyncRequestOnMainThreadWithBlock(void (^block)(JFFSimpleBlock),
                                              NSTimeInterval timeout);
