//
//  NSThread+CoreBlockUtils.m
//  CreditCalendar
//
//  Created by Наиль  on 20.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSThread+CoreBlockUtils.h"

@interface NSObject (BlockExecutionPrivate)

- (void) __performBlock:(void(^)(void))block;

@end

@implementation NSObject (BlockExecutionPrivate)

- (void) __performBlock:(void (^)(void))block
{
    if ( block != nil)
    {
        block();
    }
}

@end


@implementation NSThread (SoulBlockExecution)

- (void) corePerformBlockSync:(void (^)(void))block
{
    if ( [NSThread currentThread] == self)
    {
        block();
        return;
    }
    
    [self performSelector:@selector(__performBlock:) onThread:self withObject:block waitUntilDone:YES];
}

- (void) corePerformBlockAsync:(void (^)(void))block
{
    
    if ( [NSThread currentThread] == self)
    {
        block();
        return;
    }
    
    [self performSelector:@selector(__performBlock:) onThread:self withObject:block waitUntilDone:NO];
}

@end
