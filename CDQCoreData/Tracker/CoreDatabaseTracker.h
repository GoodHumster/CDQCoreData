//
//  CoreDatabaseTracker.h
//  CDQCoreData
//
//  Created by Наиль  on 30.11.2017.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CoreFetchedResultsController;

@interface CoreDatabaseTracker : NSObject

- (void) coreLookForCoreFetchedResultsController:(CoreFetchedResultsController *)controller forOwner:(NSObject *)owner;

- (void) coreWipeForOwner:(NSObject *)owner;

@end
