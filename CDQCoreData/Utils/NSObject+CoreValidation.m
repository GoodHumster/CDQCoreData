//
//  NSObject+CoreValidation.m
//  CDQCoreData
//
//  Created by Наиль  on 16.10.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "NSObject+CoreValidation.h"
#import "NSObject+CoreUtils.h"

@implementation NSObject(CoreValidation)

- (BOOL) coreValidateValue:(__autoreleasing id *)value forKey:(NSString *)key
{
    if (!value || !key)
    {
        return NO;
    }
    
    id sVl = [self valueForKey:key];
    
    if ([sVl isKindOfClass:[*value class]])
    {
        if ([self coreIskindOfClassEncode:@encode(BOOL) forKey:key])
        {
            BOOL vlB = [*value boolValue];
            *value = [NSNumber numberWithBool:vlB];
        }
        
        return YES;
    }
    
    if ([sVl isKindOfClass:[NSNumber class]])
    {
        *value = [*value coreNumber];
        return YES;
    }
    
    return NO;
}

- (BOOL) coreIsKindOfClass:(Class)cls forKey:(NSString *)key
{
    NSString *selfClassName = NSStringFromClass(cls);
    
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    
    if (!property)
    {
        return NO;
    }
    
    const char *attributes = property_getAttributes(property);
    NSString *attr = [NSString stringWithUTF8String:attributes];
    
    return [attr containsString:selfClassName];
}

- (BOOL) coreIskindOfClassEncode:(const char *)encodeClsString forKey:(NSString *)key
{
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    
    if (!property)
    {
        return NO;
    }
    
    const char *attributes = property_getAttributes(property);
    NSString *attr = [NSString stringWithUTF8String:attributes];
    const char *encodeType = [[attr substringWithRange:NSMakeRange(1, 1)] UTF8String];
    
    return strcmp(encodeType, encodeClsString) == 0;
}

@end
