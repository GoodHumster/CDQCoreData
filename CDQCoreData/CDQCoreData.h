//
//  CoreDatabaseManager.h
//  CDQCoreData
//
//  Created by Наиль  on 21.08.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreDataFetchStatement.h"
#import "CDQCoreDataConfiguration.h"

@class NSEntityDescription;

typedef void (^DatabaseAsquireRecordCompletionBlock) (NSArray * results);

@interface CDQCoreData : NSObject

@property (nonatomic, strong) CDQCoreDataConfiguration * _Nullable config;

+ (instancetype) coreDataWithConfiguration:( CDQCoreDataConfiguration * _Nullable )config;
+ (instancetype) coreData;

- (void)saveAndWait:(BOOL)wait;

- (BOOL) isHasRecords:(Class _Nonnull )cls;

- (BOOL) isHasEqualRecords:(id _Nonnull )obj;

- (NSArray*) getEqualRecords:(id)obj;

- (NSInteger) countOfRecords:(Class)cls;

- (void) deleteRecord:(id)record;

- (void) insertRecord:(id)record;

- (void) updateRecord:(id)record;

- (void) removeAll:(Class)cls;

- (void) insertOrUpdateRecord:(id)record;

- (NSArray *) getRecordsWithStatement:(CoreDataFetchStatement *)fetchStatement;

- (BOOL) getRecordsWithStatement:(CoreDataFetchStatement *)fetchStatement onThread:(NSThread *)thread andCompletionBlock:(DatabaseAsquireRecordCompletionBlock)completionBlock;

- (NSArray *) acquireRecordsForClass:(Class)cls;

- (NSArray *) acquireRecordsForClass:(Class)cls withPredicate:(NSPredicate *)predicate;

- (NSArray *) acquireRecordsForClass:(Class)cls predicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors;

- (BOOL) acquireRecordsForClass:(Class)cls onThread:(NSThread *)thread withCompletionBlock:(DatabaseAsquireRecordCompletionBlock)completionBlock;

- (BOOL) acquireRecordsForClass:(Class)cls onThread:(NSThread *)thread predicate:(NSPredicate *)predicate withCompletionBlock:(DatabaseAsquireRecordCompletionBlock)completionBlock;

- (BOOL) acquireRecordsForClass:(Class)cls onThread:(NSThread *)thread predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors withCompletionBlock:(DatabaseAsquireRecordCompletionBlock)completionBlock;

@end
