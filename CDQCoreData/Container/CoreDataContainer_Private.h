//
//  CoreDataContainer_Private.h
//  CDQCoreData
//
//  Created by Administrator on 12/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#ifndef CoreDataContainer_Private_h
#define CoreDataContainer_Private_h

#import "CoreDataContainer.h"
#import "CoreDataMapper.h"

@interface CoreDataContainer()

@property (nonatomic, strong) NSString *storageId;

@property (nonatomic, strong) NSArray *cInsertedOrUpdatedObjects;

@property (nonatomic, strong) NSArray *cDeletedObjects;

- (void) commitChanges;

- (BOOL) enumerateObjectsToSaveWithCollisionBlock:(CoreDataObject *(^)(id<NSCopying> record,NSEntityDescription *entityDescription))collisionBlock usingBlock:(void(^)(CoreDataObject *objToSave,kCoreDataOperation cdOperation,id record))enumerationBlock;

@end


#endif /* CoreDataContainer_Private_h */
