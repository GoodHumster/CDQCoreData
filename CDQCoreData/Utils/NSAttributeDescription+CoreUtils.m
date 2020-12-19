//
//  NSAttributeDescription+CoreUtils.m
//  CDQCoreData
//
//  Created by Administrator on 12/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import "NSAttributeDescription+CoreUtils.h"

@implementation NSAttributeDescription (CoreUtils)


- (NSPredicate *)corePridcateWithKey:(NSString *)key andArgument:(id)argument
{
    NSAttributeType attrType = self.attributeType;
    
    switch (attrType) {
        case NSStringAttributeType:
            return [NSPredicate predicateWithFormat:@"%K LIKE %@",key,argument];
        default:
            return [NSPredicate predicateWithFormat:@"%K == %@",key,argument];
    }
}

@end
