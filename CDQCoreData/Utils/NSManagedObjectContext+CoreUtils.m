//
//  NSManagedObjectContext+CoreUtils.m
//  CDQCoreData
//
//  Created by Наиль  on 28.02.2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import "NSManagedObjectContext+CoreUtils.h"

@implementation NSManagedObjectContext (CoreUtils)

- (void) coreInsert:(id)records
{
    if ([records isKindOfClass:[NSArray class]] || [records isKindOfClass:[NSSet class]])
    {
        for (id obj in records)
        {
            [self insertObject:obj];
        }
        return;
    }
    
    [self insertObject:records];
}

@end
