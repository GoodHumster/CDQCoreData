//
//  CoreDataContainer.m
//  CDQCoreData
//
//  Created by Administrator on 12/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "CoreDataContainer_Private.h"

#import "CoreDataObject_Private.h"
#import "CoreDataMapper.h"

#import "DebugAsserts.h"

@interface CoreDataContainer()

@property (nonatomic, weak) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong, nullable) NSArray *insertOrUpdated;

@property (nonatomic, strong, nullable) NSArray *deleted;

@property (nonatomic, strong) NSString *identifier;

@end

@implementation CoreDataContainer

- (instancetype) initWithManagedObjectModel:(nonnull NSManagedObjectModel *)managedObjectModel
{
    if ( ( self = [super init]) == nil )
    {
        return nil;
    }
    self.cDeletedObjects = [NSArray new];
    self.cInsertedOrUpdatedObjects = [NSArray new];
    self.identifier = [[NSUUID UUID] UUIDString];
    self.locked = NO;
    self.managedObjectModel = managedObjectModel;
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ deallocated",NSStringFromClass(self.class));
    self.cInsertedOrUpdatedObjects = nil;
    self.cDeletedObjects = nil;
}

- (id) copyWithZone:(NSZone *)zone
{
    CoreDataContainer *other = [CoreDataContainer new];
    other.managedObjectModel = self.managedObjectModel;
    other.insertOrUpdated = self.insertOrUpdated;
    other.deleted = self.deleted;
    other.cInsertedOrUpdatedObjects = self.cInsertedOrUpdatedObjects;
    other.cDeletedObjects = self.cDeletedObjects;
    other.identifier = self.identifier;
    
    return other;
}

- (NSArray *)insertOrUpdated
{
    if (!_insertOrUpdated)
    {
        _insertOrUpdated = [NSArray new];
    }
    
    return _insertOrUpdated;
}

- (NSArray *)deleted
{
    if (!_deleted)
    {
        _deleted = [NSArray new];
    }
    
    return _deleted;
}

#pragma mark - Public API method

- (BOOL) inserOrUpdateRecord:(id<NSCopying>)record
{
    if (!record)
    {
        return NO;
    }
    
    @synchronized (self)
    {
        NSMutableArray *mC = [self.insertOrUpdated mutableCopy];
        NSUInteger index = [mC indexOfObject:record];
        
        if (index != NSNotFound)
        {
            [mC replaceObjectAtIndex:index withObject:record];
            return YES;
        }
        
        [mC addObject:[(id)record copy]];
        self.insertOrUpdated = [mC copy];
    }
    
    return YES;
}

- (BOOL) deleteRecord:(id<NSCopying>)record
{
    if (!record)
    {
        return NO;
    }
    
    @synchronized (self)
    {
        NSMutableArray *mC = [self.deleted mutableCopy];
        
        if ([mC indexOfObject:record] != NSNotFound)
        {
            NSLog(@"%@ Record already insert in transaction for inserting,updating or deleting:%@",NSStringFromClass(self.class),record);
            return NO;
        }
        
        [mC addObject:[(id)record copy]];
        
        self.deleted = [mC copy];
    }
  
    return YES;
}

- (void)wipe
{
    self.insertOrUpdated = nil;
    self.deleted = nil;
}

#pragma mark - Private API methods

- (void)commitChanges
{
    @synchronized (self)
    {
        if (self.insertOrUpdated)
        {
            self.cInsertedOrUpdatedObjects = [self.insertOrUpdated copy];
        }
        
        if (self.deleted)
        {
            self.cDeletedObjects = [self.deleted copy];
        }
        
        self.insertOrUpdated = nil;
        self.deleted = nil;
    }
}

- (BOOL)enumerateObjectsToSaveWithCollisionBlock:(CoreDataObject *(^)(id<NSCopying>, NSEntityDescription *))collisionBlock usingBlock:(void (^)(CoreDataObject *, kCoreDataOperation,id))enumerationBlock
{
    BOOL res = YES;
    
    res &= [self doEnumerationWithCollisionBlock:collisionBlock usingBlock:enumerationBlock forObjects:self.cInsertedOrUpdatedObjects deleted:NO];
    
    res &= [self doEnumerationWithCollisionBlock:collisionBlock usingBlock:enumerationBlock forObjects:self.cDeletedObjects deleted:YES];
    
    return res;
}

#pragma mark - utils methods

- (BOOL) doEnumerationWithCollisionBlock:(CoreDataObject *(^)(id<NSCopying>, NSEntityDescription *))collisionBlock usingBlock:(void (^)(CoreDataObject *, kCoreDataOperation,id))enumerationBlock forObjects:(NSArray *)objects deleted:(BOOL)deleted
{
    if (!objects)
    {
        return NO;
    }
    
     NSManagedObjectModel *managedObjectModel = self.managedObjectModel;
    
    for (id<NSCopying>record in objects)
    {
        [CoreDataMapper coreEnumerateInputObjects:^(CoreDataObject *object, kCoreDataOperation op, id record) {
            
            if (deleted)
            {
                op = kCoreDataOperation_Delete;
            }
            
            enumerationBlock(object,op,record);
        } collisionBlock:^CoreDataObject *(id record, NSEntityDescription *entity) {
            
            if (deleted)
            {
                return nil;
            }
            
            return collisionBlock(record,entity);
            
        } forRecord:record withManagedObjectModel:managedObjectModel];
    }
    
    return YES;
}


@end
