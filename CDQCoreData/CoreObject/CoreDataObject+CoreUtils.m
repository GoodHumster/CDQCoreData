//
//  CoreDataObject+CoreUtils.m
//  CDQCoreData
//
//  Created by Administrator on 30/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import "NSObject+CoreUtils.h"
#import "CoreDataObject+CoreUtils.h"
#import "NSPropertyDescription+CoreUtils.h"



@implementation CoreDataObject (CoreUtils)

- (void) coreEnumerateReltionshipsUsingBlock:(CoreDataObjectPropertyEnumerationBlock)enumerationBlock fromOutputRecord:(id<NSCopying>)record
{
    NSDictionary *relationshipsByName = self.entity.relationshipsByName;
    NSArray *allKeys = [relationshipsByName allKeys];
    
    for (NSString *key in allKeys)
    {
        NSRelationshipDescription *relationshipDescription = [relationshipsByName objectForKey:key];
        
        id relationship = [(id)record valueForKey:key];
        
        if (!relationship)
        {
            continue;
        }
        
        if ([relationship isKindOfClass:[NSSet class]])
        {
            relationship = [relationship allObjects];
        }
        
        if (![relationship isKindOfClass:[NSArray class]])
        {
            relationship = @[relationship];
        }
        
        for (id obj in relationship)
        {
            enumerationBlock(obj,key,relationshipDescription);
        }
    }
}

- (void)coreEnumeratePropertiesUsingBlock:(CoreDataObjectPropertyEnumerationBlock)usinBlock fromOutputRecord:(id<NSCopying>)record
{
    [self coreEnumerateProperties:usinBlock forRecord:record forEntityDescription:self.entity];
}

- (void)coreEnumeratePropertiesUsingBlock:(CoreDataObjectPropertyEnumerationBlock)usinBlock
{
    [self coreEnumerateProperties:usinBlock forRecord:self forEntityDescription:self.entity];
}

- (void)coreInsertRelationships:(NSArray *)relationships withDescription:(NSRelationshipDescription *)description
{
    BOOL canInsert = ![relationships coreIsNull] && ![self coreIsNull];

    id insertedValue = description.toMany ? [NSSet setWithArray:[relationships copy]] : relationships.firstObject;
   
    if (canInsert && description.inverseRelationship)
    {
        NSRelationshipDescription *inverseRelationship = description.inverseRelationship;
        
        id (^transitionBlock) (id) = ^(id insertedValue){
            
            id inverseRls = self;
            
            if (!inverseRelationship.toMany)
            {
                return inverseRls;
            }
            
            inverseRls = [insertedValue valueForKey:description.inverseRelationship.name];
                         
            if (!inverseRls)
            {
                inverseRls = [NSSet setWithObject:self];
            }
            else
            {
                inverseRls = [inverseRls setByAddingObject:self];
            }
            return inverseRls;
        };
        
        if (description.toMany)
        {
            for (id iVl in insertedValue)
            {
                id inverseVL = transitionBlock(iVl);
                [iVl setValue:inverseVL forKey:inverseRelationship.name];
            }
        }
        else
        {
            id inverseVL = transitionBlock(insertedValue);
            [insertedValue setValue:inverseVL forKey:inverseRelationship.name];
        }
    }
    
    [self setValue:insertedValue forKey:description.name];
}

#pragma mark - utils methods

- (void) coreEnumerateProperties:(CoreDataObjectPropertyEnumerationBlock)enumerationBlock forRecord:(id)record forEntityDescription:(NSEntityDescription *)entity
{
    NSArray *keys = entity.propertiesByName.allKeys;
    
    for (NSString *k in keys)
    {
        NSPropertyDescription *property = [entity.propertiesByName valueForKey:k];
        SEL selector = NSSelectorFromString(k);
        
        if (!property)
        {
            continue;
        }
        
        if (![record respondsToSelector:selector])
        {
            continue;
        }
        
        [self willAccessValueForKey:k];
        id value = [record valueForKey:k];
        [self didAccessValueForKey:k];
        
         enumerationBlock(value,k,property);
    }
}

@end
