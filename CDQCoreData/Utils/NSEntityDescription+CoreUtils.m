//
//  NSEntityDescription+CoreUtils.m
//  CDQCoreData
//
//  Created by Administrator on 24/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import "NSEntityDescription+CoreUtils.h"

#import <objc/runtime.h>

@implementation NSEntityDescription (CoreUtils)

- (void) setParentRelatonshipsByName:(NSDictionary *)parentRelatonshipsByName
{
    objc_setAssociatedObject(self, @selector(parentRelatonshipsByName), parentRelatonshipsByName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)parentRelatonshipsByName
{
    return objc_getAssociatedObject(self, @selector(parentRelatonshipsByName));
}

@end
