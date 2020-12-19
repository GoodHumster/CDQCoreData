

//
//  CoreDatabaseManager.m
//  CDQCoreData
//
//  Created by Наиль  on 21.08.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CDQCoreData_Private.h"
#import "CDQDatabaseStorage_Private.h"

#import "CoreDataObject_Private.h"
#import "CoreDatabaseTracker.h"
#import "CoreDataMapper.h"
#import "CoreDataContainer_Private.h"


#import "NSThread+CoreManageObjectContext.h"
#import "NSManagedObjectContext+CoreUtils.h"

#import "NSObject+CoreStaticConfiguration.h"
#import "NSThread+CoreBlockUtils.h"
#import "NSObject+CoreUtils.h"

#import "DebugAsserts.h"


@interface CDQCoreData()

@property (nonatomic, strong) CDQDatabaseStorage *dbStorage;

@end

@implementation CDQCoreData

static CDQCoreData *_cachedCoreData;

#pragma mark - init methods

+ (instancetype) coreData
{
    return [CDQCoreData coreDataWithConfiguration:nil];
}

+ (instancetype) coreDataWithConfiguration:(CDQCoreDataConfiguration *)config
{
    
    if (CDQCoreData.cachedCoreData)
    {
        return CDQCoreData.cachedCoreData;
    }
    
    CDQCoreData *coreData = [[CDQCoreData alloc] initWithConfiguration:config];
    CDQCoreData.cachedCoreData = coreData;
    return coreData;
}

- (instancetype) initWithConfiguration:(CDQCoreDataConfiguration *)config
{
    if ( (self = [self init]) == nil)
    {
        return nil;
    }
    self.config = config;
    return self;
}


- (instancetype) init
{
    if ( (self = [super init]) == nil)
    {
        return nil;
    }
    self.databaseTracker = [[CoreDatabaseTracker alloc] init];
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@ deallocated",NSStringFromClass(self.class));
}

- (CDQDatabaseStorage *) dbStorage
{
    if (!_dbStorage)
    {
        _dbStorage = [[CDQDatabaseStorage alloc] initWithStorageConfiguration:self.config.storageConfiguration];
    }
    
    return _dbStorage;
}

+ (void)setCachedCoreData:(CDQCoreData *)cachedCoreData {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cachedCoreData = cachedCoreData;
    });
}

+ (CDQCoreData *)cachedCoreData {
    return  _cachedCoreData;
}

#pragma mark - Publick API methods

- (void) saveAndWait:(BOOL)wait
{
    NSManagedObjectContext *context = [self.dbStorage coreInputManagedObjectContext];
    CoreDataContainer *container = [self coreDataContainerOnCurrentThread];
    NSString *identifier = container.identifier;
    [container commitChanges];
    
    if (!context)
    {
        return;
    }
    
    [NSThread setCoreDataContainer:nil];
    
    __weak typeof(self)weakSelf = self;
    void(^executeBlock)(void) = ^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        BOOL result = [container enumerateObjectsToSaveWithCollisionBlock:^CoreDataObject *(id<NSCopying> record, NSEntityDescription *entityDescription) {
            
            NSPredicate *predicate = [CoreDataObject predicateObjectExistForRecord:record enity:entityDescription];
            NSString *name = entityDescription.name;
            
            Class managedObjectClass = NSClassFromString(entityDescription.managedObjectClassName);
            
            if ([managedObjectClass forceUpdate])
            {
                return nil;
            }
            
            return [self fetchRecordsInContext:context forEntityName:name predicate:predicate descriptors:nil].firstObject;
            
        } usingBlock:^(CoreDataObject *objToSave, kCoreDataOperation cdOperation, id record) {
            
            switch (cdOperation) {
                case kCoreDataOperation_Insert:
                    [context insertObject:objToSave];
                    break;
                case kCoreDataOperation_Delete:
                {
                    if (objToSave.managedObjectContext == context)
                    {
                        [context deleteObject:objToSave];
                        break;
                    }
                    
                    NSEntityDescription *entity = objToSave.entity;
                    NSPredicate *predicate = [CoreDataObject predicateObjectExistForRecord:record enity:entity];
                    NSString *name = entity.name;
                    
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
                    request.predicate = predicate;
                    
                    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
                    deleteRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
                    
                    
                    NSError *error = nil;
                    NSBatchDeleteResult *deleteResult = [context executeRequest:deleteRequest error:&error];
                    if (!deleteResult || error)
                    {
                        NSLog(@"%@ Failed execute delete request for enity name:%@",NSStringFromClass(self.class),[name uppercaseString]);
                        break;
                    }
                    NSDictionary *resultMap = @{NSDeletedObjectsKey:[NSSet setWithArray:deleteResult.result]};
                    [NSManagedObjectContext mergeChangesFromRemoteContextSave:resultMap intoContexts:@[blockSelf.dbStorage.mainContext]];
                    break;
                }
                default:
                    break;
            }
            
        }];
        
        if (!result)
        {
            NSLog(@"%@ Failed save objects to database",NSStringFromClass(self.class));
            return;
        }
        
        if ([context hasChanges])
        {
            NSError *error = nil;
            NSLog(@"%@ Saving container: %@",NSStringFromClass(self.class),identifier);
            if (![context save:&error] || error)
            {
                NSLog(@"%@ Failed save changes: %@",NSStringFromClass(self.class),error);
                return;
            }
        }
    };
    
    if (!wait)
    {
        [context performBlock:executeBlock];
    }
    else
    {
        [context performBlockAndWait:executeBlock];
    }
}

- (void) insertRecord:(id)record
{
    [self insertOrUpdateRecord:record];
    return;
}

- (void) deleteRecord:(id)record
{
    if (!record)
    {
        return;
    }
    
    CoreDataContainer *container = [self coreDataContainerOnCurrentThread];
    
    if (!container)
    {
        NSLog(@"%@ Not found any one container",NSStringFromClass(self.class));
        return;
    }
    
    if (![container deleteRecord:record])
    {
        NSLog(@"%@ Failed delete record: %@",NSStringFromClass(self.class),record);
    }
}


- (void) removeAll:(Class)cls
{
    NSString *name = [CoreDataMapper coreEnityNameForClass:cls withManagedObjectModel:self.dbStorage.managedObjectModel];
    
    if (![self isHasRecords:cls])
    {
        NSLog(@"%@ Entity: %@ doesn't have any records",NSStringFromClass(self.class),[name uppercaseString]);
        return;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:name];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    
    NSError *error = nil;
    if (![self.dbStorage.mainContext executeRequest:deleteRequest error:&error] || error)
    {
        NSLog(@"%@ Failed clear database: %@",NSStringFromClass(self.class),name);
    }
}

- (void) updateRecord:(id)record
{
    if (!record)
    {
        return;
    }
    
    [self insertOrUpdateRecord:record];
}

- (void) insertOrUpdateRecord:(id)record
{
    if (!record)
    {
        return;
    }
    
    CoreDataContainer *container = [self coreDataContainerOnCurrentThread];
    
    if (!container)
    {
        NSLog(@"%@ Not found any one container",NSStringFromClass(self.class));
        return;
    }
    
    if (![container inserOrUpdateRecord:record])
    {
        NSLog(@"%@ Failed insert or update record: %@",NSStringFromClass(self.class),record);
    }
}

- (BOOL) isHasRecords:(Class)cls
{
    NSString *name = [CoreDataMapper coreEnityNameForClass:cls withManagedObjectModel:self.dbStorage.managedObjectModel];
    
    if (!name)
    {
        return NO;
    }
    
    NSManagedObjectContext *moc = self.dbStorage.mainContext;
    __block NSUInteger count = 0;
    __weak typeof(self) weakSelf = self;
    
    [moc performBlockAndWait:^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        count = [blockSelf countOfRecordsContext:moc forEntityName:name predicate:nil descriptors:nil];
    }];
    
    return count > 0;
}

- (NSArray *) getEqualRecords:(id)obj
{
    if (!obj)
    {
        return nil;
    }

    NSManagedObjectModel *objectModel = self.dbStorage.managedObjectModel;
    NSString *name = [CoreDataMapper coreEnityNameForClass:[obj class] withManagedObjectModel:objectModel];
    DEBUG_ASSERTS_NOT_NIL(name);
    
    NSEntityDescription *entity = [objectModel.entitiesByName valueForKey:name];
    DEBUG_ASSERTS_NOT_NIL(entity);
    
    NSPredicate *predicate = [CoreDataObject predicateObjectExistForRecord:obj enity:entity];
    DEBUG_ASSERTS_NOT_NIL(predicate);
    
    NSManagedObjectContext *context = self.dbStorage.mainContext;
    __block NSArray *records = nil;
    
    __weak typeof(self) weakSelf = self;
    [context performBlockAndWait:^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        records = [self fetchRecordsInContext:context forEntityName:name predicate:predicate descriptors:nil];
        
        if (records)
        {
            records = [CoreDataMapper coreOutputObjects:records];
        }
    }];
    
    return records;
}

- (BOOL) isHasEqualRecords:(id)obj
{
    if (!obj)
    {
        return NO;
    }
    
    NSManagedObjectModel *objectModel = self.dbStorage.managedObjectModel;
    NSString *name = [CoreDataMapper coreEnityNameForClass:[obj class] withManagedObjectModel:objectModel];
    NSEntityDescription *entity = [objectModel.entitiesByName valueForKey:name];
    NSPredicate *predicate = [CoreDataObject predicateObjectExistForRecord:obj enity:entity];
    
    NSManagedObjectContext *moc = self.dbStorage.mainContext;
    __block NSUInteger count = 0;
    __weak typeof(self) weakSelf = self;
    
    [moc performBlockAndWait:^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        count = [blockSelf countOfRecordsContext:moc forEntityName:name predicate:predicate descriptors:nil];
    }];
    
    
    return count > 0;
}

- (NSInteger)countOfRecords:(Class)cls
{
    if (cls == nil)
    {
        return 0;
    }
    
    NSString *name = [CoreDataMapper coreEnityNameForClass:cls withManagedObjectModel:self.dbStorage.managedObjectModel];
    
    if (!name)
    {
        return 0;
    }
    
    NSManagedObjectContext *moc = self.dbStorage.mainContext;
    __block NSUInteger count = 0;
    __weak typeof(self) weakSelf = self;
    [moc performBlockAndWait:^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        count = [blockSelf countOfRecordsContext:moc forEntityName:name predicate:nil descriptors:nil];
    }];
    
    return count;
}

- (NSArray *)getRecordsWithStatement:(CoreDataFetchStatement *)fetchStatement
{
    DEBUG_ASSERTS_NOT_NIL(fetchStatement);
    DEBUG_ASSERTS_NOT_NIL(fetchStatement.recordClass);
    
    NSFetchRequest *fetchRequest = [self makeFetchRequestFromStatement:fetchStatement];
    
    if (!fetchRequest)
    {
        return nil;
    }
    
    __block NSArray *results = nil;
    NSManagedObjectContext *context = self.dbStorage.mainContext;
    
    __weak typeof(self) weakSelf = self;
    [context performBlockAndWait:^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        results = [blockSelf fetchRecordsInContext:context withStatement:fetchStatement];
        
        if (results)
        {
            results = [CoreDataMapper coreOutputObjects:results];
        }
    }];
    
    return results;
}

- (BOOL)getRecordsWithStatement:(CoreDataFetchStatement *)fetchStatement onThread:(NSThread *)thread andCompletionBlock:(DatabaseAsquireRecordCompletionBlock)completionBlock
{
    DEBUG_ASSERTS_NOT_NIL(fetchStatement);
    DEBUG_ASSERTS_NOT_NIL(fetchStatement.recordClass);
    
    NSFetchRequest *fetchRequest = [self makeFetchRequestFromStatement:fetchStatement];
    
    if (!fetchRequest)
    {
        return NO;
    }
    
    NSManagedObjectContext *moc = self.dbStorage.mainContext;
    
    __weak typeof(self) weakSelf = self;
    [moc performBlock:^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        NSArray *results = [blockSelf fetchRecordsInContext:moc withStatement:fetchStatement];
        
        if (results)
        {
            results = [CoreDataMapper coreOutputObjects:results];
        }
        
        if (thread)
        {
            [thread corePerformBlockAsync:^{
                if (completionBlock)
                {
                    completionBlock(results);
                }
            }];
            return;
        }
        
        if (completionBlock)
        {
            completionBlock(results);
        }
    }];
    
    return YES;
}

- (NSArray *) acquireRecordsForClass:(Class)cls
{
    return [self acquireRecordsForClass:cls withPredicate:nil];
}

- (NSArray *) acquireRecordsForClass:(Class)cls withPredicate:(NSPredicate *)predicate
{
    return [self acquireRecordsForClass:cls predicate:predicate withSortDescriptors:nil];
}

- (NSArray *) acquireRecordsForClass:(Class)cls predicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors
{
    if (cls == nil)
    {
        return nil;
    }

    NSString *name = [CoreDataMapper coreEnityNameForClass:cls withManagedObjectModel:self.dbStorage.managedObjectModel];
    
    if (!name)
    {
        return nil;
    }
    
    __block NSArray *results = nil;
    NSManagedObjectContext *context = self.dbStorage.mainContext;
    
    __weak typeof(self) weakSelf = self;
    [context performBlockAndWait:^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        results = [blockSelf fetchRecordsInContext:context forEntityName:name predicate:predicate descriptors:sortDescriptors];
        
        if (results)
        {
            results = [CoreDataMapper coreOutputObjects:results];
        }
    }];
    
    return results;
}

- (BOOL) acquireRecordsForClass:(Class)cls onThread:(NSThread *)thread withCompletionBlock:(DatabaseAsquireRecordCompletionBlock)completionBlock
{
    return [self acquireRecordsForClass:cls onThread:thread predicate:nil withCompletionBlock:completionBlock];
}

- (BOOL) acquireRecordsForClass:(Class)cls onThread:(NSThread *)thread predicate:(NSPredicate *)predicate withCompletionBlock:(DatabaseAsquireRecordCompletionBlock)completionBlock
{
    return [self acquireRecordsForClass:cls onThread:thread predicate:predicate sortDescriptors:nil withCompletionBlock:completionBlock];
}

- (BOOL) acquireRecordsForClass:(Class)cls onThread:(NSThread *)thread predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors withCompletionBlock:(DatabaseAsquireRecordCompletionBlock)completionBlock
{
    if (cls == nil)
    {
        return NO;
    }

    NSString *name = [CoreDataMapper coreEnityNameForClass:cls withManagedObjectModel:self.dbStorage.managedObjectModel];
    DEBUG_ASSERTS_VALID([NSString class], name);

    if (!name)
    {
        return NO;
    }

    NSManagedObjectContext *moc = self.dbStorage.mainContext;

    __weak typeof(self) weakSelf = self;
    [moc performBlock:^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        NSArray *results = [blockSelf fetchRecordsInContext:moc forEntityName:name predicate:predicate descriptors:sortDescriptors];
    
        if (results)
        {
            results = [CoreDataMapper coreOutputObjects:results];
        }
        
        if (thread)
        {
            [thread corePerformBlockAsync:^{
                if (completionBlock)
                {
                    completionBlock(results);
                }
            }];
            return;
        }

        if (completionBlock)
        {
            completionBlock(results);
        }
    }];

    return YES;
}

#pragma mark - Private API methods

- (NSManagedObjectModel *)managedObjectModel
{
    return self.dbStorage.managedObjectModel;
}

- (NSManagedObjectContext *) mainContext
{
    return self.dbStorage.mainContext;
}

- (void) wipeDatabase
{
    [self.dbStorage wipeStorage];
    self.dbStorage = nil;
}

- (void) disconnectDatabase
{
    [self.dbStorage disconnectSotrage];
    self.dbStorage = nil;
    
}

- (NSString *) entityNameForClass:(Class)cls
{
    if (!cls)
    {
        return nil;
    }
    
    return [CoreDataMapper coreEnityNameForClass:cls withManagedObjectModel:self.dbStorage.managedObjectModel];
}

- (NSFetchRequest *)makeFetchRequestFromStatement:(CoreDataFetchStatement *)statement
{
    NSString *entityName = [self entityNameForClass:statement.recordClass];
    
    if (!entityName)
    {
        return nil;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = @[sortDescriptor];
    request.predicate = statement.predicate;
    
    if (statement.sortDescriptors && statement.sortDescriptors.count > 0)
    {
        request.sortDescriptors = statement.sortDescriptors;
    }
    
    request.fetchLimit = statement.fetchLimit != NSNotFound ? statement.fetchLimit : request.fetchLimit;
    request.fetchOffset = statement.fetchOffset;
    request.fetchBatchSize = statement.fetchBatchSize;
    request.resultType = statement.resultType;
    
    if (statement.propertiesToFetch)
    {
        request.propertiesToFetch = statement.propertiesToFetch;
    }
    
    return request;
}

#pragma mark - Fetch request methods

- (NSInteger) countOfRecordsContext:(NSManagedObjectContext *)context forEntityName:(NSString *)name predicate:(NSPredicate *)predicate descriptors:(NSArray *)descriptors
{
    NSFetchRequest *request = [self createFetchRequestWithEntityName:name predicate:predicate sortDescriptors:descriptors resultType:NSCountResultType];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if (error)
    {
        NSLog(@"%@ Failed acquire records with error:%@",NSStringFromClass(self.class),error);
        return NSNotFound;
    }
    
    return count;
}

- (NSArray *) fetchRecordsInContext:(NSManagedObjectContext *)context withStatement:(CoreDataFetchStatement *)fetchStatement
{
    DEBUG_ASSERTS_NOT_NIL(fetchStatement);
    DEBUG_ASSERTS_NOT_NIL(fetchStatement.recordClass);
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [self makeFetchRequestFromStatement:fetchStatement];
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        NSLog(@"%@ Failed acquire records with error:%@",NSStringFromClass(self.class),error);
        return nil;
    }
    
    return results;
}

- (NSArray *) fetchRecordsInContext:(NSManagedObjectContext *)context forEntityName:(NSString *)name predicate:(NSPredicate *)predicate descriptors:(NSArray *)descriptors
{
    DEBUG_ASSERTS_NOT_NIL(name);
    DEBUG_ASSERTS_NOT_NIL(context);

    
    NSError *error = nil;
    NSFetchRequest *request = [self createFetchRequestWithEntityName:name predicate:predicate sortDescriptors:descriptors resultType:NSManagedObjectResultType];
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error)
    {
        NSLog(@"%@ Failed acquire records with error:%@",NSStringFromClass(self.class),error);
        return nil;
    }
    
    return results;
}

#pragma mark - utils methods

- (NSFetchRequest *) createFetchRequestWithEntityName:(NSString *)name predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)descriptors resultType:(NSFetchRequestResultType)resultType
{
    NSFetchRequest *fetchReguest = [[NSFetchRequest alloc] initWithEntityName:name];
    fetchReguest.predicate = predicate;
    fetchReguest.sortDescriptors = descriptors;
    fetchReguest.resultType = resultType;

    return fetchReguest;
}

- (CoreDataContainer *) coreDataContainerOnCurrentThread
{
    if (!self.dbStorage)
    {
        return nil;
    }

    CoreDataContainer *container = [NSThread currentCoreDataContainer];
        
    if (!container)
    {
        [self createCoreDataContainerOnCurrentThread];
        container = [NSThread currentCoreDataContainer];
    }
        
    if (![container.storageId isEqualToString:self.dbStorage.uuid])
    {
        [self createCoreDataContainerOnCurrentThread];
        container = [NSThread currentCoreDataContainer];
    }
        
    return container;
}

- (void) createCoreDataContainerOnCurrentThread
{
    if (!self.dbStorage)
    {
        return;
    }
 
    CoreDataContainer *container = [[CoreDataContainer alloc] initWithManagedObjectModel:self.dbStorage.managedObjectModel];
    container.storageId = self.dbStorage.uuid;
    [NSThread setCoreDataContainer:container];
 }

@end


