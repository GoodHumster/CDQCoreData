//
//  CoreDataMapper.m
//  CDQCoreData
//
//  Created by Наиль  on 05.02.2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CoreDataMapper.h"
#import "CoreDataObject_Private.h"
#import "CoreDataObject+CoreUtils.h"

#import "NSObject+CoreSerialize.h"
#import "NSObject+CoreUtils.h"
#import "NSEntityDescription+CoreUtils.h"
#import "NSPropertyDescription+CoreUtils.h"
#import "NSArray+CoreData.h"

@implementation CoreDataMapper

#pragma mark - Public API methods

+ (NSString *) coreEnityNameForClass:(Class)cls withManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    if ([cls isSubclassOfClass:[CoreDataObject class]])
    {
        return [cls entityName];
    }
    
    NSArray *entities = [managedObjectModel entities];
    
    if (!entities)
    {
        return nil;
    }
    
    NSPredicate *entityPredicate = [self predicateEnitiesForClass:cls];
    NSEntityDescription *entity = [entities filteredArrayUsingPredicate:entityPredicate].firstObject;
    
    if (!entity)
    {
        return nil;
    }
    
    return entity.name;
}

+ (NSArray *) coreOutputObjects:(NSArray *)inputObjects
{
    __block NSMutableArray *outputObjects = [NSMutableArray new];
    
    [self enumerateOutputObjects:^(id record) {
        
        [outputObjects addObject:record];
        
    } forObjects:inputObjects withParentObject:nil];
    
    return [outputObjects copy];
}

+ (void)coreEnumerateInputObjects:(void (^)(CoreDataObject *, kCoreDataOperation, id))enumerationBlock collisionBlock:(CoreDataObject *(^)(id, NSEntityDescription *))collisionBlock forRecord:(id)record withManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    [self enumerateInputObjects:enumerationBlock collisionBlock:collisionBlock forRecord:record withManagedObjectModel:managedObjectModel inversRelatonship:NO];
}

#pragma mark - Predicate methods

+ (NSPredicate *) predicateEnitiesForClass:(Class)cls
{
    return [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
#pragma unused(bindings)
        NSEntityDescription *enity = [evaluatedObject coreAsClass:[NSEntityDescription class]];
        NSString *clsName = enity.managedObjectClassName;
        
        Class cdmClass = NSClassFromString(clsName);
        
        if (![cdmClass isSubclassOfClass:[CoreDataObject class]])
        {
            return NO;
        }
        
        Class outCls = [cdmClass managedObjectOutputClass];
        
        return outCls != nil && outCls == cls;
    }];
}

#pragma mark - enumeration methods

+ (void) enumerateInputObjects:(void (^)(CoreDataObject *, kCoreDataOperation, id))enumerationBlock collisionBlock:(CoreDataObject *(^)(id, NSEntityDescription *))collisionBlock forRecord:(id)record withManagedObjectModel:(NSManagedObjectModel *)managedObjectModel inversRelatonship:(BOOL)inversRelatonship
{
    Class objCls = [record class];
    NSArray *entities = [managedObjectModel entities];
    
    if (!entities)
    {
        return;
    }
    
    NSPredicate *entityPredicate = [self predicateEnitiesForClass:objCls];
    NSEntityDescription *entity = [entities filteredArrayUsingPredicate:entityPredicate].firstObject;
    NSArray<CoreDataObject *> *(^mapRelationshipsBlock)(NSRelationshipDescription *description,id relationsips) = ^NSArray<CoreDataObject *> *(NSRelationshipDescription *description,id value){
        
        if (inversRelatonship || !value)
        {
            return nil;
        }
        
        NSArray *relationships = [NSArray coreRelationshipsArrayFromValue:value];
        __block NSMutableArray *rls = [NSMutableArray new];
    
        for (id relation in relationships)
        {
            [self enumerateInputObjects:^(CoreDataObject *object, kCoreDataOperation op, id record) {

                enumerationBlock(object,op,record);

                if (![(id)relation isKindOfClass:[record class]])
                {
                    return;
                }

                [rls addObject:object];

            } collisionBlock:collisionBlock forRecord:relation withManagedObjectModel:managedObjectModel inversRelatonship:(description.inverseRelationship != nil)];
        }
        
        return rls;
    };
    
    CoreDataObject *obj = nil;
    kCoreDataOperation op = kCoreDataOperation_Update;
    
    if (collisionBlock)
    {
        obj = collisionBlock(record,entity);
    }
    
    if (!obj)
    {
        obj = [self createCoreDataObjectFromEntity:entity];
        op = kCoreDataOperation_Insert;
    }
    
    if (![self validateIfNeededRecord:record forEntity:entity])
    {
        return;
    }
    
    if (enumerationBlock)
    {
        enumerationBlock(obj,op,record);
    }
    
    NSString *primaryKey = [self getPrimaryKeyForEntityDescription:entity];
    __block needUpdate = NO;
    [obj coreEnumeratePropertiesUsingBlock:^(id value, NSString *key, NSPropertyDescription *property) {
        
        NSRelationshipDescription *relationshipDescription = [property coreAsClass:[NSRelationshipDescription class]];
        
        if (relationshipDescription)
        {
            NSArray *cdRelationships = mapRelationshipsBlock(relationshipDescription,value);
            
            if (!cdRelationships || cdRelationships.count == 0)
            {
                return;
            }
            
            id oldValue = [obj valueForKey:key];
            
            if (!oldValue)
            {
                [obj coreInsertRelationships:cdRelationships withDescription:relationshipDescription];
                return;
            }
            
            NSArray *oldRelationships = [NSArray coreRelationshipsArrayFromValue:oldValue];
            
            for (CoreDataObject *obj in oldRelationships)
            {
                if ([obj.class forceUpdate])
                {
                    enumerationBlock(obj,kCoreDataOperation_Delete,nil);
                    continue;
                }
                
                if (!relationshipDescription.toMany)
                {
                    id cdValue = cdRelationships.firstObject;
                    if ([obj objectID] != [cdValue objectID])
                    {
                        enumerationBlock(obj,kCoreDataOperation_Delete,nil);
                    }
                    continue;
                }

                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.objectID == %@",obj.objectID];
                CoreDataObject *newObj = [cdRelationships filteredArrayUsingPredicate:predicate].firstObject;

                if (!newObj)
                {
                    enumerationBlock(obj,kCoreDataOperation_Delete,nil);
                }
            }
            
            needUpdate = YES;
            [obj coreInsertRelationships:cdRelationships withDescription:relationshipDescription];
        
            return;
        }
        
        if (property.validationPredicates || property.validationPredicates.count > 0)
        {
            NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:property.validationPredicates];
            
            if (![predicate evaluateWithObject:value])
            {
                return;
            }
        }
        
        if ([key isEqualToString:primaryKey] && value == nil)
        {
            return;
        }
        
        [obj setValue:value forKey:key];
        
    } fromOutputRecord:record];
    
}

+ (void) enumerateOutputObjects:(void(^)(id record))enumerationBlock forObjects:(NSArray *)coreDataObjects withParentObject:(CoreDataObject *)parentObject
{
    if (!coreDataObjects)
    {
        return;
    }
    
    for (CoreDataObject *obj in coreDataObjects)
    {
        if (![obj isKindOfClass:[CoreDataObject class]])
        {
            continue;
        }
        
        Class outClass = [[obj class] managedObjectOutputClass];
        id outObj = [outClass new];
        
        [obj coreEnumeratePropertiesUsingBlock:^(id value, NSString *key, NSPropertyDescription *description) {
           
            NSRelationshipDescription *relationshipDescription = [description coreAsClass:[NSRelationshipDescription class]];
            SEL selector = NSSelectorFromString(key);
            
            if (![outObj respondsToSelector:selector])
            {
                return;
            }
            
            if (relationshipDescription)
            {
                if (!value || [value isEqual:parentObject])
                {
                    return;
                }

                NSArray *relationships = [NSArray coreRelationshipsArrayFromValue:value];
                NSRelationshipDescription *inverseRelationship = relationshipDescription.inverseRelationship;
                
                __block NSMutableArray *mRls = [NSMutableArray new];
                [self enumerateOutputObjects:^(id record) {
                    
                    if (inverseRelationship && [record respondsToSelector:inverseRelationship.nameSelectorSetter])
                    {
                        [record setValue:[outObj copy] forKey:inverseRelationship.name];
                    }
                    
                    [mRls addObject:record];
    
                } forObjects:relationships withParentObject:obj];
                
                if (relationshipDescription.toMany)
                {
                    [outObj setValue:[NSSet setWithArray:mRls] forKey:key];
                }
                else
                {
                    [outObj setValue:mRls.firstObject forKey:key];
                }
                
                return;
            }
            
            if (!value)
            {
                return;
            }
            
            if ([outObj respondsToSelector:NSSelectorFromString(key)])
            {
                [outObj setValue:value forKey:key];
            }
            
        }];
        
        if (enumerationBlock)
        {
            enumerationBlock(outObj);
        }
    }
}

#pragma mark - utils methods

+ (id) createCoreDataObjectFromEntity:(NSEntityDescription *)entity
{
    NSString *clsName = entity.managedObjectClassName;
    Class cdmClass = NSClassFromString(clsName);
    
    return [cdmClass coreDataObjectWithEntityDescription:entity];
}

+ (SEL) createSelectorFromPropertyDescription:(NSPropertyDescription *)propertyDescription
{
    NSString *inversetSetter = [NSString stringWithFormat:@"set%@:",[propertyDescription.name capitalizedString]];
    SEL inversSelector = NSSelectorFromString(inversetSetter);
    
    return inversSelector;
}

+ (BOOL) validateIfNeededRecord:(id)record forEntity:(NSEntityDescription *)entityDescription
{
    NSString *cdmClassName = entityDescription.managedObjectClassName;
    Class cdmClass = NSClassFromString(cdmClassName);
    
    if (![cdmClass isSubclassOfClass:[CoreDataObject class]])
    {
        return NO;
    }
    
    NSString *primaryKey = [cdmClass primaryKey];
    
    if (!primaryKey)
    {
        return YES;
    }
    
    NSPropertyDescription *propertyDescription = [entityDescription.propertiesByName valueForKey:primaryKey];
    
    id value = [record valueForKey:primaryKey];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:propertyDescription.validationPredicates];
    
    if (!predicate || !propertyDescription.validationPredicates || propertyDescription.validationPredicates.count == 0)
    {
        return YES;
    }
    
    return [predicate evaluateWithObject:value];
}

+ (NSString *) getPrimaryKeyForEntityDescription:(NSEntityDescription *)entityDescription
{
    NSString *cdmClassName = entityDescription.managedObjectClassName;
    Class cdmClass = NSClassFromString(cdmClassName);
    
    if (![cdmClass isSubclassOfClass:[CoreDataObject class]])
    {
        return nil;
    }
    
    return [cdmClass primaryKey];
}

@end
