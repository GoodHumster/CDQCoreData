//
//  DatabaseStorage.m
//  CDQCoreData
//
//  Created by Наиль  on 12.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDQDatabaseStorage_Private.h"

#import "NSObject+CoreStaticConfiguration.h"

#import "DebugAsserts.h"

static NSString *const kDatabaseStoragePathName = @"com.cdq.core.data";

@interface CDQDatabaseStorage()
{
    @private
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinatorInput;
    NSPersistentStoreCoordinator *_persistentStoreCoordinatorOutput;
    NSURL *_storeURL;
    
}

@property (nonatomic, strong) NSManagedObjectContext *mainContext;

@property (nonatomic, strong) NSManagedObjectContext *inputContext;

@property (nonatomic, weak) CDQCoreDataStorageConfiguration *config;
 

@end

@implementation CDQDatabaseStorage

@synthesize uuid = _uuid;

#pragma mark - init methods

- (instancetype) initWithStorageConfiguration:(CDQCoreDataStorageConfiguration *)config
{
    if ( (self = [super init]) == nil)
    {
        return nil;
    }
    self.config = config;
    
    if (![self createDatabase])
    {
        return nil;
    }
    
    return self;
}

- (BOOL) createDatabase
{
    NSString *dbPath = [self pathToDatabase];
    
    if (!dbPath)
    {
        return NO;
    }
    
    NSString *parentPath = [dbPath stringByDeletingLastPathComponent];
    NSString *pathName = [dbPath lastPathComponent];
               
    [self scanAndClearPath:parentPath than:pathName];
    
    NSString *dataModelPath = [NSObject coreStaticCoreDataFilePath];
    NSURL *url = [NSURL URLWithString:dataModelPath];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    
    NSURL *documentURL = [[NSURL fileURLWithPath:dbPath] URLByAppendingPathComponent:@"DataModel.sqlite"];
    NSError *error = nil;
    
    // REMOVE DATABASE CLEAR (wipe data)
    
    _storeURL = documentURL;
    _persistentStoreCoordinatorInput = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    _persistentStoreCoordinatorInput.name = [[NSUUID UUID] UUIDString];
    _persistentStoreCoordinatorOutput = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];

    
    if (![_persistentStoreCoordinatorInput addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:documentURL options:[self storeOptions] error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        NSLog(@"%@ Try remove database",NSStringFromClass(self.class));
        
        if ([self removeStoreAtURL:documentURL])
        {
            return [self createDatabase];
        }
        
        NSException *e = [NSException exceptionWithName:NSGenericException reason:@"Failed add store" userInfo:[error userInfo]];
        
        [e raise];
    }
    
    if (![_persistentStoreCoordinatorOutput addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:documentURL options:[self storeOptions] error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        NSLog(@"%@ Try remove database",NSStringFromClass(self.class));
        
        if ([self removeStoreAtURL:documentURL])
        {
            return [self createDatabase];
        }
        
        NSException *e = [NSException exceptionWithName:NSGenericException reason:@"Failed add store" userInfo:[error userInfo]];
        
        [e raise];
    }
    
    
    _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0"))
    {
        _mainContext.mergePolicy = [NSMergePolicy overwriteMergePolicy];
    }
    else
    {
        _mainContext.mergePolicy = NSOverwriteMergePolicy;
    }
    [_mainContext setPersistentStoreCoordinator:_persistentStoreCoordinatorOutput];
    
    _mainContext.name=@"mainContext";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];

    _inputContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_inputContext setPersistentStoreCoordinator:_persistentStoreCoordinatorInput];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0"))
    {
        _inputContext.mergePolicy = [NSMergePolicy overwriteMergePolicy];
    }
    else
    {
        _inputContext.mergePolicy = NSOverwriteMergePolicy;
    }
    _inputContext.name=@"inputContext";
    
    return YES;
}

#pragma mark - Private API methods

- (void) reconnectStorage
{
    _managedObjectModel = nil;
    _persistentStoreCoordinatorInput = nil;
    _persistentStoreCoordinatorOutput = nil;
    
    self.mainContext = nil;
    
    BOOL res = [self createDatabase];
    
    if (!res)
    {
        DEBUG_ASSERT_MESSAGE("Failed create database storage");
    }
}

- (void) disconnectSotrage
{
    _managedObjectModel = nil;
    _persistentStoreCoordinatorInput = nil;
    _persistentStoreCoordinatorOutput = nil;
    
    
    _inputContext = nil;
    self.mainContext = nil;
}

- (void) wipeStorage
{
    NSPersistentStoreCoordinator *persistentStore = _persistentStoreCoordinatorInput;
    [persistentStore destroyPersistentStoreAtURL:_storeURL withType:NSSQLiteStoreType options:[self storeOptions] error:nil];
    
    [self disconnectSotrage];
}

- (NSManagedObjectModel *) managedObjectModel
{
    return _managedObjectModel;
}

#pragma mark - Publick API methods

- (NSString *)uuid
{
    if (!_uuid)
    {
        _uuid = [[NSUUID UUID] UUIDString];
    }
    
    return _uuid;
}

- (BOOL) coreIsValidManagedObjectContext:(NSManagedObjectContext *)context
{
    if (!context)
    {
        return NO;
    }
    
    NSPersistentStoreCoordinator *coordinator = context.persistentStoreCoordinator;
    return [coordinator.name isEqualToString:_persistentStoreCoordinatorInput.name];
}

- (NSManagedObjectContext *) coreInputManagedObjectContext
{
    return _inputContext;
}

#pragma mark - Background Context Notifications

- (void) mocDidSaveNotification:(NSNotification *)notification
{
    if (!notification)
    {
        return;
    }
    
    NSManagedObjectContext *moc = notification.object;
    
    if ([moc isEqual:self.mainContext])
    {
        return;
    }
    
    if (!notification.userInfo)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^mergeBlock)(void) = ^{
        __strong typeof(weakSelf) blockSelf = weakSelf;
        
        if (!blockSelf)
        {
            return;
        }
        
        [self meregeChanges:notification.userInfo intoContext:self.mainContext];
    };
    
    if ([NSThread isMainThread]) {
        mergeBlock();
        return;
    }
    
    [self.mainContext performBlock:mergeBlock];
}

#pragma mark - utils methods

- (BOOL)wipeStoreAtURL:(NSURL *)storeURL
{
    NSLog(@"%@: Try to wipe database",NSStringFromClass(self.class));
    
    if ([self removeStoreAtURL:storeURL])
    {
     //   NSUserDefaults.standardUserDefaults.coreShouldWipeDatabase = NO;
        return [self createDatabase];
    }
    
    [[NSException exceptionWithName:NSGenericException reason:@"Failed removing store" userInfo:nil] raise];
    return NO;
}

- (BOOL) removeStoreAtURL:(NSURL *)url
{
    if (!url)
    {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    DEBUG_ASSERTS_NOT_NIL(fileManager);
    
    NSError *error = nil;
    if ( ![fileManager removeItemAtURL:url error:&error] || error )
    {
        return NO;
    }
    
    return YES;
}

- (NSDictionary *) storeOptions
{
    return @{ NSInferMappingModelAutomaticallyOption: @YES,
              NSMigratePersistentStoresAutomaticallyOption: @YES,
              NSSQLitePragmasOption: @{@"synchronous": @"OFF"}};
}

- (NSString *) pathToDatabase
{
    NSString *dbPath = self.config.storagePath;
    
    if (!dbPath)
    {
        dbPath = [NSObject coreStaticConfigurationCacheBaseDirPath];
        NSString *parentPath = [dbPath stringByDeletingLastPathComponent];
        NSString *pathName = [dbPath lastPathComponent];
        
        dbPath = [parentPath stringByAppendingPathComponent:kDatabaseStoragePathName];
        dbPath = [dbPath stringByAppendingPathComponent:pathName];
        
        if (!dbPath)
        {
            return nil;
        }
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:dbPath])
    {
        NSError *error = nil;
        BOOL res = [fileManager createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error != nil || !res)
        {
            return nil;
        }
    }
    
    return dbPath;
}

- (void) scanAndClearPath:(NSString *)path than:(NSString *)name;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    DEBUG_ASSERTS_VALID([NSFileManager class], fileManager);
    
    NSError *error = nil;
    NSArray *content = [fileManager contentsOfDirectoryAtPath:path error:&error];
    
    if (error || content.count == 0)
    {
        return;
    }
    
    for (NSString *p in content)
    {
        if ([p isEqualToString:name])
        {
            continue;
        }
        
        NSString *fullPath = [path stringByAppendingPathComponent:p];
        [fileManager removeItemAtPath:fullPath error:nil];
    }
}

- (void) meregeChanges:(NSDictionary *)userInfo intoContext:(NSManagedObjectContext *)context
{
    if (!userInfo)
    {
        return;
    }
    
    NSArray<NSString *> *keys = [userInfo allKeys];
    
    if (!context)
    {
        return;
    }
    
    NSLog(@"%@ Begin merge changes in main context",NSStringFromClass(self.class));
    
    for (NSString *key in keys)
    {
        if (![key isEqualToString:NSUpdatedObjectsKey] && ![key isEqualToString:NSDeletedObjectsKey] && ![key isEqualToString:NSInsertedObjectsKey])
        {
            continue;
        }
        
        NSSet *objsSet = [userInfo objectForKey:key];
        
        if (!objsSet || objsSet.count == 0)
        {
            continue;
        }
        
        NSMutableArray *objs = [NSMutableArray new];
        
        for (NSManagedObject *obj in [objsSet allObjects])
        {
            NSError *error = nil;
            NSManagedObject *exsitObjc = [context existingObjectWithID:obj.objectID error:&error];
            
            if (!exsitObjc || error)
            {
                continue;
            }
            
            [objs addObject:exsitObjc.objectID];
        }
        
        NSLog(@"%@ Merge changes in main context",NSStringFromClass(self.class));
        [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{key:[objs copy]} intoContexts:@[context]];
    }
    
    NSLog(@"%@ Complete merge in main context",NSStringFromClass(self.class));
}

@end


//
//    __weak typeof(self) weakSelf = self;
//    [moc performBlockAndWait:^{
//        __strong typeof(weakSelf) blockSelf = weakSelf;
//
//        NSDictionary *userInfo = notification.userInfo;
//        NSArray<NSString *> *keys = [userInfo allKeys];
//        NSManagedObjectContext *context = blockSelf.outputMoc;
//
//        if (!context)
//        {
//            return;
//        }
//
//        for (NSString *key in keys)
//        {
//            if (![key isEqualToString:NSUpdatedObjectsKey] && ![key isEqualToString:NSDeletedObjectsKey] && ![key isEqualToString:NSInsertedObjectsKey])
//            {
//                continue;
//            }
//
//            NSSet *objsSet = [userInfo objectForKey:key];
//
//            if (!objsSet || objsSet.count == 0)
//            {
//                continue;
//            }
//
//            NSMutableArray *objs = [NSMutableArray new];
//
//            for (NSManagedObject *obj in [objsSet allObjects])
//            {
//                NSError *error = nil;
//                NSManagedObject *exsitObjc = [context existingObjectWithID:obj.objectID error:&error];
//
//                if (!exsitObjc || error)
//                {
//                    continue;
//                }
//
//                [objs addObject:exsitObjc.objectID];
//            }
//
//            [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{key:[objs copy]} intoContexts:@[context]];
//        }
//    }];
