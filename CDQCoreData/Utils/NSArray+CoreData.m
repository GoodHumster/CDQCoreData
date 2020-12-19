//
//  NSArray+CoreData.m
//  CDQCoreData
//
//  Created by Administrator on 01/12/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "NSArray+CoreData.h"
#import "NSObject+CoreUtils.h"

@implementation NSArray (CoreData)

+ (NSArray *)coreRelationshipsArrayFromValue:(id)value
{
    if (!value)
    {
        return nil;
    }
    
    id relationships = nil;
    
    NSSet *sets = [value coreAsClass:[NSSet class]];

    if (sets)
    {
        relationships = [sets allObjects];
    }
    else
    {
        relationships = [value coreAsClass:[NSArray class]];
    }
    
    if (!relationships)
    {
        relationships = @[value];
    }
    
    return relationships;
}

@end
