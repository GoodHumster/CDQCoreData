//
//  CoreFetchResultsController.m
//  CDQCoreData
//
//  Created by Наиль  on 28.11.2017.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CoreFetchedResultsController.h"

#import "CDQCoreData_Private.h"

#import "CoreDataObject_Private.h"

#import "DebugAsserts.h"

@interface CoreFetchedResultsController()

@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, assign) Class coreDataObjectClass;

@end

@implementation CoreFetchedResultsController

+ (id) controllerWithCoreDataObjectClass:(Class)cls withFetchedBlock:(CoreFetchedResultsControllerTrackingBlock)trakingBlock
{
   
    CDQCoreData *dbManager = CDQCoreData.cachedCoreData;
    DEBUG_ASSERTS_VALID([CDQCoreData class], dbManager);
    DEBUG_ASSERTS_NOT_NIL(dbManager);
    
    NSString *entityName = [dbManager entityNameForClass:cls];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSManagedObjectContext *mocOutput = dbManager.mainContext;
    DEBUG_ASSERTS_VALID([NSManagedObjectContext class], mocOutput);
    DEBUG_ASSERTS_NOT_NIL(mocOutput);
    
    CoreFetchedResultsController *controller = [[CoreFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:mocOutput sectionNameKeyPath:nil cacheName:nil];
    
    controller.coreDataObjectClass  = cls;
    controller.keyPath = entityName;
    controller.trakingBlock= trakingBlock;
    
    return controller;
}

+ (id)  controllerWithRequest:(NSFetchRequest *)request withTrackingBlock:(CoreFetchedResultsControllerTrackingBlock)trackingBlock
{
    CDQCoreData *dbManager = CDQCoreData.cachedCoreData;
    DEBUG_ASSERTS_VALID([CDQCoreData class], dbManager);
    DEBUG_ASSERTS_NOT_NIL(dbManager);
    
    NSManagedObjectContext *mocOutput = dbManager.mainContext;
    DEBUG_ASSERTS_VALID([NSManagedObjectContext class], mocOutput);
    DEBUG_ASSERTS_NOT_NIL(mocOutput);
    
    CoreFetchedResultsController *controller = [[CoreFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:mocOutput sectionNameKeyPath:nil cacheName:nil];
    
    controller.coreDataObjectClass = NSClassFromString(request.entity.managedObjectClassName);
    controller.keyPath = request.entityName;
    controller.trakingBlock= trackingBlock;
    
    return controller;
}

- (void) dealloc
{
    NSLog(@"%@ deallocated",NSStringFromClass(self.class));
}

#pragma mark - NSFetchedResultsController methods

- (NSArray *)fetchedObjects
{
    NSArray *fetchedObjects = [super fetchedObjects];
    NSFetchRequest *fetchRequest = self.fetchRequest;
    
    if (fetchedObjects.count >= fetchRequest.fetchLimit && fetchRequest.fetchLimit > 0)
    {
        return [fetchedObjects subarrayWithRange:NSMakeRange(0, fetchRequest.fetchLimit)];
    }
    
    return fetchedObjects;
}

@end

