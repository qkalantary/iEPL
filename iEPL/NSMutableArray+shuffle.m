//
//  NSMutableArray+shuffle.m
//  iEPL
//
//  Created by Q Kalantary on 4/8/15.
//  Copyright (c) 2015 Q Kalantary. All rights reserved.
//

#import "NSMutableArray+shuffle.h"

@implementation NSMutableArray (shuffle)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end
