//
//  CoreDataObject+CoreUtils.h
//  CDQCoreData
//
//  Created by Administrator on 30/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import "CoreDataObject.h"

//typedef void (^CoreDataObjectRelationshipEnumerationBlock) (id value,NSString *key,NSRelationshipDescription *description);

typedef void (^CoreDataObjectPropertyEnumerationBlock) (id value,NSString *key,NSPropertyDescription *description);

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataObject (CoreUtils)

- (void) coreEnumerateReltionshipsUsingBlock:(CoreDataObjectPropertyEnumerationBlock)enumerationBlock fromOutputRecord:(id<NSCopying>)record;

- (void) coreEnumeratePropertiesUsingBlock:(CoreDataObjectPropertyEnumerationBlock)usinBlock fromOutputRecord:(id<NSCopying>)record;

- (void) coreEnumeratePropertiesUsingBlock:(CoreDataObjectPropertyEnumerationBlock)usinBlock;

- (void) coreInsertRelationships:(NSArray *)relationships withDescription:(NSRelationshipDescription *)description;

@end

NS_ASSUME_NONNULL_END
