//
//  NSThread+CoreManageObjectContext.h
//  CDQCoreData
//
//  Created by Наиль  on 26.02.2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class CoreDataContainer;

@interface NSThread (CoreManageObjectContext)

+ (NSManagedObjectContext *) currentManagedObjectContext;

+ (void) setCurrentManagedObjectContext:(NSManagedObjectContext *)context;

+ (CoreDataContainer *) currentCoreDataContainer;

+ (void) setCoreDataContainer:(CoreDataContainer *)container;

@end
