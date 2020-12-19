//
//  CoreDataObject.h
//  CDQCoreData
//
//  Created by Наиль  on 11.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoreDataObject;

@interface CoreDataObject : NSManagedObject<NSCopying>

@property (nonatomic, assign) NSInteger id;

+ (NSString *) entityName;

+ (NSString *) primaryKey;

+ (NSArray *) searchKeys;

+ (BOOL) needFullScann;

+ (BOOL) forceUpdate;

+ (Class) managedObjectOutputClass;

@end
