//
//  CoreDataFetchStatement.m
//  CDQCoreData
//
//  Created by Administrator on 13/05/2019.
//  Copyright © 2019 Alef. All rights reserved.
//

#import "CoreDataFetchStatement.h"

@implementation CoreDataFetchStatement

- (instancetype) init
{
    if ( ( self = [super init]) == nil )
    {
        return nil;
    }
    
    self.resultType = NSManagedObjectResultType;
    self.propertiesToFetch = nil;
    self.fetchLimit = NSNotFound;
    self.fetchOffset = 0;
    self.fetchBatchSize = 0;
    
    return self;
}

+ (id) fetchStatementForClass:(Class)recordClass
{
    CoreDataFetchStatement *statement = [CoreDataFetchStatement new];
    statement.recordClass = recordClass;
    return statement;
}

+ (id) fethcAndTrackingStatementForClass:(Class)recordClass andOwner:(id)owner
{
    CoreDataFetchStatement *statement = [CoreDataFetchStatement new];
    statement.recordClass = recordClass;
    statement.observeOwner = owner;
    return statement;
}

@end

