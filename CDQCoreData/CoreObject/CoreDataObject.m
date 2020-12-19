//
//  CoreDataObject.m
//  CDQCoreData
//
//  Created by Наиль  on 11.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CDQCoreData_Private.h"
#import "CoreDataObject_Private.h"

#import "NSObject+CoreUtils.h"
#import "NSAttributeDescription+CoreUtils.h"
#import "NSEntityDescription+CoreUtils.h"

#import "DebugAsserts.h"

@implementation CoreDataObject

@synthesize id = _id;
@synthesize parentObject = _parentObject;
@synthesize replacedRelationsByObjectID = _replacedRelationsByObjectID;
@synthesize hasInversionRelationship = _hasInversionRelationship;

+ (Class)managedObjectOutputClass
{
    return self.class;
}

+ (NSString *) entityName
{
    DEBUG_ASSERTS_TRUE(FALSE);
    NSLog(@"%@ Must be overided by subclass",NSStringFromClass(self.class));
    return nil;
}

+ (NSString *) primaryKey
{
    return nil;
}

+ (BOOL) needFullScann
{
    return NO;
}

+ (BOOL)forceUpdate
{
    return NO;
}

+ (NSArray *)searchKeys
{
    return nil;
}

- (void) setId:(NSInteger)id
{
    [self willChangeValueForKey:@"id"];
    _id = id;
    [self didChangeValueForKey:@"id"];
}

- (NSInteger) id
{
    [self willAccessValueForKey:@"id"];
    NSInteger id = _id;
    [self didAccessValueForKey:@"id"];
 
    return id;
}



#pragma mark - Private API

+ (id) coreDataObjectWithEntityDescription:(NSEntityDescription *)entity
{
    CoreDataObject *obj = [[self alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    obj.parentObject = nil;
    
    return obj;
}

- (NSPredicate *)predicateObjectExist
{
    return [self.class predicateObjectExistForRecord:self enity:self.entity];
}

- (NSPredicate *)predicateObjectSearch
{
    return [self.class predicateObjectSearchForRecord:self enity:self.entity];
}

- (NSMutableDictionary *)replacedRelationsByObjectID
{
    if (!_replacedRelationsByObjectID)
    {
        _replacedRelationsByObjectID = [NSMutableDictionary new];
    }
    
    return _replacedRelationsByObjectID;
}

+ (NSPredicate *) predicateObjectExistForRecord:(id)record enity:(NSEntityDescription *)entityDescription
{
    if (!entityDescription || !record)
    {
        return nil;
    }
    
    Class cls = NSClassFromString(entityDescription.managedObjectClassName);
    NSString *primaryKey = [cls primaryKey];
    
    if (primaryKey)
    {
        id value = [record valueForKey:primaryKey];
        
        if (!value)
        {
            return nil;
        }
        
        NSAttributeDescription *attrDescription = [entityDescription.attributesByName valueForKey:primaryKey];
        
        if (!attrDescription)
        {
            return nil;
        }
        
      //  NSString *predicateFormat = [attrDescription corePredicateOperationFormat];
        return [attrDescription corePridcateWithKey:primaryKey andArgument:value];
    }
    
    return [self predicateObjectSearchForRecord:record enity:entityDescription];
}

+ (NSPredicate *) predicateObjectSearchForRecord:(id)record enity:(NSEntityDescription *)entityDescription
{
    if (!entityDescription || !record)
    {
        return nil;
    }
    
    Class cls = NSClassFromString(entityDescription.managedObjectClassName);
    
    NSArray *searchKeys = [cls searchKeys];
    
    if (!searchKeys)
    {
        searchKeys = entityDescription.propertiesByName.allKeys;
    }
    
    NSDictionary *attributesByName = entityDescription.attributesByName;
    NSDictionary *relationshipsByName = entityDescription.relationshipsByName;
    NSMutableArray<NSPredicate *> *predicates = [NSMutableArray new];
    for (NSString *key in searchKeys)
    {
        SEL keySelector = NSSelectorFromString(key);
        
        if (![record respondsToSelector:keySelector])
        {
            continue;
        }
        
        if ([relationshipsByName valueForKey:key])
        {
            continue;
        }
        
        id value = [record valueForKey:key];
        
        if (!value)
        {
            continue;
        }
        
        NSAttributeDescription *attrDescription = [attributesByName valueForKey:key];
        
        if (!attrDescription)
        {
            continue;
        }
        
       // NSString *predicateFormat = [attrDescription corePredicateOperationFormat];
        [predicates addObject:[attrDescription corePridcateWithKey:key andArgument:value]];
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

- (void)copyInObject:(CoreDataObject *)other withRelatonshipBlock:(CoreDataObjectRelatonshipBlock)relatonshipBlock
{
    NSEntityDescription *description = self.entity;
    NSDictionary *properties = description.propertiesByName;
    NSDictionary *realtonships = description.relationshipsByName;
    
    for (NSString *key in [properties allKeys])
    {
        id value = [self valueForKey:key];
        
        if (!value)
        {
            continue;
        }
        
        if ([self.entity.parentRelatonshipsByName valueForKey:key])
        {
            id parent = [self.entity.parentRelatonshipsByName valueForKey:key];
            [other setValue:parent forKey:key];
            continue;
        }
        
        if ([realtonships valueForKey:key])
        {
            NSRelationshipDescription *rlDesc = [realtonships valueForKey:key];
            id rlOthValue = [other valueForKey:key];
            
            NSArray *rlObjs = [self collectionRelatonshipsWithValue:value andDescription:rlDesc];
            NSArray *rlOthObjs = [self collectionRelatonshipsWithValue:rlOthValue andDescription:rlDesc];
            
            if (!rlObjs)
            {
                continue;
            }
            
            NSUInteger index = 0;
            NSMutableSet *mSet = [NSMutableSet new];
            for (CoreDataObject *obj in rlObjs)
            {
                NSEntityDescription *rlEntity = obj.entity;
                BOOL inversion = NO;
                
                if ([rlDesc.inverseRelationship.destinationEntity.name isEqualToString:self.entity.name])
                {
                    inversion = YES;
                    NSRelationshipDescription *inRlDesc = rlDesc.inverseRelationship;
                    rlEntity.parentRelatonshipsByName = @{inRlDesc.name:other};
                }
              
                CoreDataObject *rlOthObj = nil;
                
                if (rlOthObjs.count > index)
                {
                    rlOthObj = [rlOthObjs objectAtIndex:index];
                }
                
                index += 1;
                
                if (relatonshipBlock)
                {
                    CoreDataObject *rlObj = relatonshipBlock(rlEntity.parentRelatonshipsByName,obj,rlOthObj);
                    
                    if (rlObj)
                    {
                        [mSet addObject:rlObj];
                    }
                    continue;
                }
                
                if (rlOthObj)
                {
                    [obj copyInObject:rlOthObj withRelatonshipBlock:relatonshipBlock];
                    [mSet addObject:rlOthObj];
                    continue;
                }
                
                [mSet addObject:[obj copy]];
                
            }
            
            value = [mSet copy];
            
            if (!rlDesc.toMany)
            {
                value = [mSet allObjects].firstObject;
            }
        }
        
        [other setValue:value forKey:key];
    }
    
    other.parentObject = self.parentObject;
}

- (void)mergeWithForceInsertBlock:(void (^)(CoreDataObject *))forceInsertBlock
{
    if (!self.replacedRelationsByObjectID || self.replacedRelationsByObjectID.count == 0)
    {
        return;
    }
    
    NSEntityDescription *entityDescription = self.entity;
    NSDictionary *relationshipsByName = entityDescription.relationshipsByName;
    NSArray *allKeys = [relationshipsByName allKeys];

    for (NSString *key in allKeys)
    {
        NSRelationshipDescription *relationshipDescription = [relationshipsByName valueForKey:key];
        
        if (!relationshipDescription.toMany)
        {
            continue;
        }
        
        NSString *name = relationshipDescription.inverseRelationship.name;
        NSSet *set = [self valueForKey:relationshipDescription.name];
        NSMutableArray *mRls = [[set allObjects] mutableCopy];
    
        for (NSUInteger i = 0; i < mRls.count; i++)
        {
            CoreDataObject *obj = [mRls objectAtIndex:i];
            CoreDataObject *upObj = [self.replacedRelationsByObjectID objectForKey:obj.objectID];
            
            if (!upObj)
            {
                continue;
            }
            
            if (name && [upObj respondsToSelector:NSSelectorFromString(name)])
            {
                if ([upObj valueForKey:name])
                {
                    forceInsertBlock(obj);
                    [mRls replaceObjectAtIndex:i withObject:obj];
                    continue;
                }
            }
            
            [mRls replaceObjectAtIndex:i withObject:upObj];
            [self.replacedRelationsByObjectID removeObjectForKey:obj.objectID];
            
            if (self.replacedRelationsByObjectID.count == 0)
            {
                break;
            }
        }
        
        set = [NSSet setWithArray:mRls];
        [self setValue:set forKey:key];
    }
}


//- (void)mergeWithUpdateObjects:(NSDictionary<NSManagedObjectID *,NSManagedObject *> *)updateObjects
//{
//    if (!updateObjects)
//    {
//        return;
//    }
//    
//    NSArray *objectIDs = [updateObjects allKeys];
//    
//    NSEntityDescription *entityDescription = self.entity;
//    NSDictionary *relationshipsByName = entityDescription.relationshipsByName;
//    NSArray *allKeys = [relationshipsByName allKeys];
//    
//    for (NSString *key in allKeys)
//    {
//        NSRelationshipDescription *relatonshipDescription = [relationshipsByName valueForKey:key];
//        NSMutableArray<NSManagedObjectID *> *rlObjectIDs = [[self objectIDsForRelationshipNamed:relatonshipDescription.name] mutableCopy];
//        NSMutableArray *insertedObjectIDs = [rlObjectIDs mutableCopy];
//        [insertedObjectIDs removeObjectsInArray:objectIDs];
//        [rlObjectIDs removeObjectsInArray:insertedObjectIDs];
//        
//        id value = [self valueForKey:key];
//        NSArray *relationshipsSource = [self collectionRelatonshipsWithValue:value andDescription:relatonshipDescription];
//        
//        for (NSManagedObjectID *objectId in rlObjectIDs)
//        {
//            CoreDataObject *object = [updateObjects valueForKey:objectId];
//            
//        }
//    }
//    
//}

//- (void)enumerateRelationshipObjects:(CoreDataObjectRelatonshipBlock)enumerationBlock
//{
//    NSEntityDescription *description = self.entity;
//    NSDictionary *relatonships = description.relationshipsByName;
//
//    if (!relatonships || relatonships.count == 0)
//    {
//        return;
//    }
//
//    for (NSString *key in relatonships.allKeys)
//    {
//        id value = [self valueForKey:key];
//
//        if (!value)
//        {
//            continue;
//        }
//
//        NSRelationshipDescription *rlDesc = [relatonships valueForKey:key];
//        NSArray *rlObjs = [self collectionRelatonshipsWithValue:value andDescription:rlDesc];
//
//        if (!rlObjs)
//        {
//            continue;
//        }
//
//        for (CoreDataObject *obj in rlObjs)
//        {
//
//        }
//
//
//    }
//}


#pragma mark - NSObject protocol methods

- (id) copyWithZone:(NSZone *)zone
{
    #pragma unused(zone)
    NSManagedObjectContext *context = nil;
    
    if (self.managedObjectContext && self.updated)
    {
        context = self.managedObjectContext;
    }
    
    id other = [[[self class] alloc] initWithEntity:self.entity insertIntoManagedObjectContext:context];
    
    if (self.managedObjectContext)
    {
        if (self.inserted)
        {
            [self.managedObjectContext insertObject:other];
        }
        
        if (self.deleted)
        {
            [self.managedObjectContext deleteObject:other];
        }
    }
    
    [self copyInObject:other withRelatonshipBlock:nil];
    return other;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}

#pragma mark - utils methods

- (NSArray *) collectionRelatonshipsWithValue:(id)value andDescription:(NSRelationshipDescription *)rlDesc
{
    if (!value || !rlDesc)
    {
        return nil;
    }
    
    if ([value isKindOfClass:[NSArray class]])
    {
        return value;
    }
        
    if ([value isKindOfClass:[NSSet class]])
    {
        return [value allObjects];
    }
    
    return @[value];
}

@end
