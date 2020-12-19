//
//  CoreDataObject_Private.h
//  CDQCoreData
//
//  Created by Наиль  on 24.11.2017.
//  Copyright © 2017 Alef. All rights reserved.
//

#import "CoreDataObject.h"

@class NSRelationshipDescription;
@class NSManagedObjectID;
@class NSManagedObject;

typedef CoreDataObject *(^CoreDataObjectRelatonshipBlock)(NSDictionary *parentRelatonshipsByName,CoreDataObject *rlSrcObj,CoreDataObject *rlOthObj);

typedef void(^CoreDataObjectRelatonshipEnumerateBlock) (CoreDataObject *rlObj,NSRelationshipDescription *rlDesc,NSString *key);

@interface CoreDataObject()

@property (nonatomic, assign) BOOL hasInversionRelationship;

@property (nonatomic, weak) CoreDataObject *parentObject;

@property (nonatomic, strong) NSMutableDictionary *replacedRelationsByObjectID;

/**
 * Create new core data object without in manage object context
 */
+ (id) coreDataObjectWithEntityDescription:(NSEntityDescription *)entity;
/**
 * Copy all properties in specific object and call relationship block if that implementated/
 */
- (void) copyInObject:(CoreDataObject *)other withRelatonshipBlock:(CoreDataObjectRelatonshipBlock)relatonshipBlock;

- (void) mergeWithForceInsertBlock:(void(^)(CoreDataObject *obj))forceInsertBlock;

- (NSPredicate *) predicateObjectExist;

- (NSPredicate *) predicateObjectSearch;

+ (NSPredicate *) predicateObjectExistForRecord:(id)record enity:(NSEntityDescription *)entityDescription;

+ (NSPredicate *) predicateObjectSearchForRecord:(id)record enity:(NSEntityDescription *)entityDescription;

@end
