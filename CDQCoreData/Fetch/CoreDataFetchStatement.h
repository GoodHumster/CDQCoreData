//
//  CoreDataFetchStatement.h
//  CDQCoreData
//
//  Created by Administrator on 13/05/2019.
//  Copyright © 2019 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataFetchStatement : NSObject

@property (nonatomic, assign) Class recordClass;
@property (nonatomic, weak) id observeOwner;

@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSArray<NSSortDescriptor *> *sortDescriptors;

@property (nonatomic) NSUInteger fetchLimit;
@property (nonatomic) NSUInteger fetchOffset;
@property (nonatomic) NSUInteger fetchBatchSize;

@property (nonatomic, strong) NSArray<NSString *> *propertiesToFetch;
@property (nonatomic, assign) NSFetchRequestResultType resultType;

+ (id) fetchStatementForClass:(Class)recordClass;
+ (id) fethcAndTrackingStatementForClass:(Class)recordClass andOwner:(id)owner;

@end





