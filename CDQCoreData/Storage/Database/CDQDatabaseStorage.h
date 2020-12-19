//
//  DatabaseStorage.h
//  CDQCoreData
//
//  Created by Наиль  on 12.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import "CDQCoreDataStorageConfiguration.h"

@class NSManagedObjectContext;

@interface CDQDatabaseStorage : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;

@property (nonatomic, strong, readonly) NSString *uuid;

- (instancetype) initWithStorageConfiguration:(CDQCoreDataStorageConfiguration *)config;
/**
 * Create child input managed object context.
 */

- (NSManagedObjectContext *) coreInputManagedObjectContext;

- (BOOL) coreIsValidManagedObjectContext:(NSManagedObjectContext *)context;

@end
