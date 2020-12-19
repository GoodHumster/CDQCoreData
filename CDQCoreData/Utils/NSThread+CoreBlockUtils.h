//
//  NSThread+CoreBlockUtils.h
//  CreditCalendar
//
//  Created by Наиль  on 20.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

@interface NSThread(SoulBlockExecution)

- (void) corePerformBlockAsync:(void(^)(void))block;

- (void) corePerformBlockSync:(void(^)(void))block;

@end
