//
//  CoreDataMapper.h
//  CDQCoreData
//
//  Created by Наиль  on 05.02.2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, kCoreDataOperation)
{
    kCoreDataOperation_Insert = 0,
    kCoreDataOperation_Update,
    kCoreDataOperation_Delete
};

@class NSManagedObjectContext;
@class NSManagedObjectModel;
@class CoreDataObject;

@interface CoreDataMapper : NSObject

+ (void) coreEnumerateInputObjects:(void(^)(CoreDataObject *object,kCoreDataOperation op,id record))enumerationBlock collisionBlock:(CoreDataObject*(^)(id record,NSEntityDescription *entity))collisionBlock forRecord:(id)record withManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

+ (NSArray *) coreOutputObjects:(NSArray *)inputObjects;

+ (NSString *) coreEnityNameForClass:(Class)cls withManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

@end

