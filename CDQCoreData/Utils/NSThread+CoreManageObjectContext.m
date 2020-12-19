//
//  NSThread+CoreManageObjectContext.m
//  CDQCoreData
//
//  Created by Наиль  on 26.02.2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <objc/runtime.h>

#import <stdlib.h>
#import <fcntl.h>
#import <errno.h>
#import <string.h>
#import <stdbool.h>
#import <sys/time.h>

#import <mach-o/dyld.h>
#import <mach/task.h>

#import "NSThread+CoreManageObjectContext.h"
//#import "NSThread+CoreBlockUtils.h"

@implementation NSThread (CoreManageObjectContext)

- (NSManagedObjectContext *) __threadManagedObjectContext
{
    return objc_getAssociatedObject(self, @selector(__threadManagedObjectContext));
}

- (CoreDataContainer *) __threadCoreDataContainer
{
    return objc_getAssociatedObject(self, @selector(__threadCoreDataContainer));
}

+ (NSManagedObjectContext *) currentManagedObjectContext
{
    return [[NSThread currentThread] __threadManagedObjectContext];
}

+ (void) setCurrentManagedObjectContext:(NSManagedObjectContext *)context
{
    objc_setAssociatedObject([NSThread currentThread], @selector(__threadManagedObjectContext), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)setCoreDataContainer:(CoreDataContainer *)container
{
    objc_setAssociatedObject([NSThread currentThread], @selector(__threadCoreDataContainer), container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (CoreDataContainer *)currentCoreDataContainer
{
    return [[NSThread currentThread] __threadCoreDataContainer];
}

@end
