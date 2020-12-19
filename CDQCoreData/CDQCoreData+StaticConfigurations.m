//
//  DatabaseManager+StaticConfigurations.m
//  CDQCoreData
//
//  Created by Administrator on 29/10/2019.
//  Copyright © 2019 Alef. All rights reserved.
//

#import "CDQCoreData+StaticConfigurations.h"

@implementation CDQCoreData (StaticConfigurations)

#pragma mark - Public API methods

+ (NSArray *)getClassesNeedRemovedForVersion:(NSString *)version
{
    NSDictionary *map = [self getClassesNeedRemovedMap];
    return [map objectForKey:version];
}


#pragma mark - utils methods

+ (NSDictionary *)getClassesNeedRemovedMap
{
    return @{
               // @"1.7.3":@[CDMCredit.class]
            };
}


@end
