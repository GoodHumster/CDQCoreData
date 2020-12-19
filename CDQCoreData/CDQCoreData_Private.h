//
//  DatabaseManager_Private.h
//  CDQCoreData
//
//  Created by Наиль  on 20.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import "CDQCoreData.h"

@class NSManagedObjectContext;
@class CoreDatabaseTracker;

@interface CDQCoreData()

@property (class, nonatomic, strong) CDQCoreData *cachedCoreData;

@property (nonatomic, weak, readonly) NSManagedObjectContext *mainContext;

@property (nonatomic, strong) CoreDatabaseTracker *databaseTracker;


- (NSManagedObjectModel *) managedObjectModel;

- (NSString *) entityNameForClass:(Class)cls;

- (NSFetchRequest *) makeFetchRequestFromStatement:(CoreDataFetchStatement *)statement;

- (void) disconnectDatabase;

- (void) wipeDatabase;

@end
