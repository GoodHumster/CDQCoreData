//
//  DatabaseManager+Requests.h
//  CDQCoreData
//
//  Created by Наиль  on 29.11.2017.
//  Copyright © 2017 Alef. All rights reserved.
//

#import "CDQCoreData.h"


@interface CDQCoreData(Tracker)

- (void) trackingRecordWithStatement:(CoreDataFetchStatement *)statement andBlock:(void(^)(NSArray *results))block;

- (void) trackingRecordForClass:(Class)cls forOwner:(id)owner withTrackingBlock:(void(^)(NSArray *results))trackingBlock;

- (void) trackingRecordForClass:(Class)cls withPredicate:(NSPredicate *)predicate forOwner:(id)owner withTrackingBlock:(void(^)(NSArray *results))trackingBlock;

- (void) trackingRecordForClass:(Class)cls withPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors forOwner:(id)owner withTrackingBlock:(void(^)(NSArray *results))trackingBlock;

- (void) wipeAllTrackersForOwner:(id)owner;

@end
