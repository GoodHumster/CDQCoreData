//
//  DatabaseManager+Requests.m
//  CDQCoreData
//
//  Created by Наиль  on 29.11.2017.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CoreDataObject.h"
#import "CoreDatabaseTracker.h"
#import "CoreDataMapper.h"

#import "CoreFetchedResultsController.h"

#import "CDQCoreData+Tracker.h"
#import "CDQCoreData_Private.h"

@implementation CDQCoreData(Tracker)

- (void) trackingRecordWithStatement:(CoreDataFetchStatement *)statement andBlock:(void (^)(NSArray *))block
{
    if (!statement || !statement.recordClass)
    {
        return;
    }
    
    NSFetchRequest *fetchRequest = [self makeFetchRequestFromStatement:statement];
    
    if (!fetchRequest)
    {
        return;
    }
    
    CoreFetchedResultsController *controller = [CoreFetchedResultsController controllerWithRequest:fetchRequest withTrackingBlock:^(NSArray *results, NSManagedObjectContext *moc) {
        
        void (^performBlock)(void) = ^{
            NSArray *res = [CoreDataMapper coreOutputObjects:results];
            
            if (block)
            {
                block(res);
            }
        };
        
        if ([NSThread isMainThread])
        {
            performBlock();
            return;
        }
        
        [moc performBlock:performBlock];
    }];
    
    if (!controller)
    {
        return;
    }
    
    static dispatch_queue_t trackingQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr_t = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, -1);
        trackingQueue = dispatch_queue_create("Tracking", attr_t);
    });
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(trackingQueue, ^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        [controller performFetch:nil];
        [blockSelf.databaseTracker coreLookForCoreFetchedResultsController:controller forOwner:statement.observeOwner];
    });
}

- (void) trackingRecordForClass:(Class)cls forOwner:(id)owner withTrackingBlock:(void (^)(NSArray *))trackingBlock
{
    [self trackingRecordForClass:cls withPredicate:nil withSortDescriptors:nil forOwner:owner withTrackingBlock:trackingBlock];
}

- (void) trackingRecordForClass:(Class)cls withPredicate:(NSPredicate *)predicate forOwner:(id)owner withTrackingBlock:(void (^)(NSArray *))trackingBlock
{
   [self trackingRecordForClass:cls withPredicate:predicate withSortDescriptors:nil forOwner:owner withTrackingBlock:trackingBlock];
}

- (void) trackingRecordForClass:(Class)cls withPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors forOwner:(id)owner withTrackingBlock:(void (^)(NSArray *))trackingBlock
{
    if (!cls)
    {
        return;
    }
    NSString *entityName = [self entityNameForClass:cls];
    
    if (!entityName)
    {
        return;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = @[sortDescriptor];
    request.predicate = predicate;
    
    if (sortDescriptors && sortDescriptors.count > 0)
    {
        request.sortDescriptors = sortDescriptors;
    }
    
    CoreFetchedResultsController *controller = [CoreFetchedResultsController controllerWithRequest:request withTrackingBlock:^(NSArray *results,NSManagedObjectContext *moc) {
        
        [moc performBlock:^{
            NSArray *res = [CoreDataMapper coreOutputObjects:results];
            
            if (trackingBlock)
            {
                trackingBlock(res);
            }
        }];
    }];
    
    if (!controller)
    {
        return;
    }
    
    static dispatch_queue_t trackingQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr_t = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, -1);
            trackingQueue = dispatch_queue_create("Tracking", attr_t);
    });
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(trackingQueue, ^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
    
        [controller performFetch:nil];
        [blockSelf.databaseTracker coreLookForCoreFetchedResultsController:controller forOwner:owner];
    });
}

- (void)wipeAllTrackersForOwner:(id)owner
{
    [self.databaseTracker coreWipeForOwner:owner];
}


@end
