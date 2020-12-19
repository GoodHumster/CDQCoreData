//
//  DatabaseStorage_Private.h
//  CDQCoreData
//
//  Created by Наиль  on 17.10.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import "CDQDatabaseStorage.h"

@interface CDQDatabaseStorage()

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

- (void) reconnectStorage;

- (void) disconnectSotrage;

- (void) wipeStorage;

@end
