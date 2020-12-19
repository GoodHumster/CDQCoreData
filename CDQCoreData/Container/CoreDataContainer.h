//
//  CoreDataContainer.h
//  CDQCoreData
//
//  Created by Administrator on 12/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CoreDataObject;
@class NSManagedObjectContext;
@class NSManagedObjectModel;


@interface CoreDataContainer : NSObject<NSCopying>

@property (nonatomic, strong, readonly, nullable) NSArray *insertOrUpdated;

@property (nonatomic, strong, readonly, nullable) NSArray *deleted;

@property (nonatomic, strong, readonly) NSString *identifier;

@property (nonatomic, assign) BOOL locked;

- (instancetype) initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

- (BOOL) inserOrUpdateRecord:(id<NSCopying>)record;

- (BOOL) deleteRecord:(id<NSCopying>)record;

- (void) wipe;

@end

NS_ASSUME_NONNULL_END
