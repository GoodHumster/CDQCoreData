//
//  CoreDatabaseTracker.m
//  CDQCoreData
//
//  Created by Наиль  on 30.11.2017.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#import "CoreDatabaseTracker.h"
#import "CoreDataObject_Private.h"

#import "CoreFetchedResultsController.h"

#import "NSObject+CoreUtils.h"

@interface NSObject(ResultControllerOwner)

@property (nonatomic, strong) NSMutableArray *resultControllers;

@end

@implementation NSObject(ResultControllerOwner)

- (void) setResultControllers:(CoreFetchedResultsController *)resultControllers
{
     objc_setAssociatedObject(self, @selector(resultControllers), resultControllers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CoreFetchedResultsController *) resultControllers
{
      return objc_getAssociatedObject(self, @selector(resultControllers));
}

@end


@interface CoreDatabaseTracker()<NSFetchedResultsControllerDelegate>
@end

@implementation CoreDatabaseTracker


- (void) coreLookForCoreFetchedResultsController:(CoreFetchedResultsController *)controller forOwner:(NSObject *)owner
{
    if (!controller)
    {
        return;
    }
    
    if (controller.trakingBlock)
    {
        controller.trakingBlock(controller.fetchedObjects,controller.managedObjectContext);
        [CoreFetchedResultsController deleteCacheWithName:nil];
    }
    
    controller.delegate = self;
    
    @synchronized (self)
    {
        if (!owner.resultControllers)
        {
            owner.resultControllers = [NSMutableArray new];
        }
        
        [owner.resultControllers addObject:controller];
    }
}

- (void)coreWipeForOwner:(NSObject *)owner
{
    owner.resultControllers = nil;
}

#pragma mark - NSFetchedResultsControllerDelegate protocol methods

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (!controller)
    {
        return;
    }
    
    NSLog(@"%@ Database content change",NSStringFromClass(self.class));
    
    CoreFetchedResultsController *coreController = [controller coreAsClass:[CoreFetchedResultsController class]];
    if (!coreController || !coreController.trakingBlock)
    {
        return;
    }
    
    NSLog(@"%@ Database notify content update %@",NSStringFromClass(self.class),coreController.keyPath);
    
    coreController.trakingBlock(coreController.fetchedObjects,controller.managedObjectContext);
}


@end
