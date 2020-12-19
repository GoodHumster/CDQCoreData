//
//  NSObject+CoreSerialize.m
//  CDQCoreData
//
//  Created by Наиль  on 07.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "CoreFormatterStorage.h"

#import "NSObject+CoreValidation.h"

#import "NSObject+CoreSerialize.h"
#import "NSDate+CoreUtils.h"
#import "NSObject+CoreUtils.h"
#import "NSData+CoreUtils.h"

#import "DebugAsserts.h"


@implementation NSObject(CoreSerializer)

+ (id) coreObjectFromDictionary:(NSDictionary *)dict
{
    if (!dict)
    {
        return nil;
    }
    
    Class<CoreJSONSerializing> cls = [self class];
    NSDictionary *scheme = [cls coreInputJSONKeyByPropertyKey];
    NSDictionary *relationships = [cls coreRelationshipPropertyKey];
    DEBUG_ASSERTS_VALID([NSDictionary class], scheme);

    if (!scheme)
    {
        return nil;
    }
    
    NSArray *keys = [scheme allKeys];
    id obj = [[self.class alloc] init];
    for (NSString *key in keys)
    {
        NSString *prName = [scheme valueForKey:key];
        id value = [dict objectForKey:key];
        
        if (!value || [value coreIsNull])
        {
            continue;
        }
        
        if (relationships)
        {
            Class realtonshipClass = [relationships valueForKey:prName];
            
            if (realtonshipClass)
            {
                if ([value isKindOfClass:[NSArray class]])
                {                    
                    value = [NSSet setWithArray:[realtonshipClass handlerJSONArray:value]];
                }
                
                if ([value isKindOfClass:[NSDictionary class]])
                {
                    value = [realtonshipClass coreObjectFromDictionary:value];
                }
            }
        }
        
        if ([self isKindOfDateClassPropertyName:prName])
        {
            value = [NSDate coreDateFromUndefinedObject:value];
        }
        
        if ([obj isEqualPropertyName:prName toClass:[NSData class]])
        {
            value = [NSData coreDataWithUndefinedObject:value];
        }
        
        if ([obj respondsToSelector:NSSelectorFromString(prName)])
        {
            [obj setValue:value forKey:prName];
        }
    }
 
    return obj;
}

- (NSDictionary *)coreToAPNSNotificationJSON
{
    Class<CoreJSONSerializing> cls = [self class];
    NSDictionary *scheme = [cls coreAPNSKeyByPropertyKey];
    return [self coreToJSONBySheme:scheme];
}

- (NSDictionary *)coreToJSON
{
    Class<CoreJSONSerializing> cls = [self class];
    NSMutableDictionary *mScheme = [[cls coreOutputJSONKeyByPropertyKey] mutableCopy];
    NSArray<NSString *> *ignoringKeys = [self coreOutputIgnoringJSONKeys];
    [mScheme removeObjectsForKeys:ignoringKeys];
    
    return [self coreToJSONBySheme:[mScheme copy]];
}

- (NSDictionary *) coreToJSONBySheme:(NSDictionary *)propertySheme
{
    Class<CoreJSONSerializing> cls = [self class];
    NSDictionary *scheme = propertySheme;
    NSDictionary *realtonships = [cls coreRelationshipPropertyKey];
    
    if (scheme == nil)
    {
        return nil;
    }
    
    DEBUG_ASSERTS_VALID([NSDictionary class], scheme);
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *keys = [scheme allKeys];
    NSDateFormatter *dateFormatter = [globalEnviroments.formatters getDateFormatterUTCTimeZoneWithFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    for (NSString *key in keys)
    {
        NSString *prName = [scheme valueForKey:key];
        
        if ([prName isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *sh = [prName coreAsClass:[NSDictionary class]];
            NSDictionary *json = [self coreToJSONBySheme:sh];
            [dict setValue:json forKey:key];
            continue;
        }
        
        SEL selector = NSSelectorFromString(prName);
        if (![self respondsToSelector:selector])
        {
            continue;
        }
        
        id value = [self valueForKey:prName];
        
        [self coreValidateValue:&value forKey:prName];
        
        if (!value)
        {
            continue;
        }
        
        if (realtonships)
        {
            Class prClass = [realtonships valueForKey:prName];
            
            if (prClass)
            {
                DEBUG_ASSERTS_VALID_PROTOCOL(CoreJSONSerializing, value);
                
                if ([value isKindOfClass:[NSSet class]])
                {
                    value = [value allObjects];
                }
                
                if ([value isKindOfClass:[NSArray class]])
                {
                    value = [self.class handlerArrayToJSON:value];
                } else {
                    value = [value coreToJSON];
                }
            }
        }
        
        if ([value isKindOfClass:[NSDate class]])
        {
            CoreJSONDateFormmaterType type = [self.class coreOutputJSONDateType];
       
            if (type == CoreJSONDateFormmaterType_String)
            {
                value = [dateFormatter stringFromDate:value];
            }
            else
            {
                NSDate *date = [value coreAsClass:[NSDate class]];
                value = @([date timeIntervalSince1970]);
            }
        }
        
        [dict setValue:value forKey:key];
        
    }
    return [dict copy];
}

#pragma mark - utils

+ (BOOL) isKindOfDateClassPropertyName:(NSString *)name
{
    objc_property_t property = class_getProperty([self class], [name UTF8String]);
    
    if (!property)
    {
        return NO;
    }
    
    const char *attributes = property_getAttributes(property);
    NSString *attr = [NSString stringWithUTF8String:attributes];
    
    return [attr containsString:@"NSDate"];
}

- (BOOL) isEqualPropertyName:(NSString *)name toClass:(Class)cls
{
    NSString *selfClassName = NSStringFromClass(cls);
    
    objc_property_t property = class_getProperty([self class], [name UTF8String]);
    
    if (!property)
    {
        return NO;
    }

    const char *attributes = property_getAttributes(property);
    NSString *attr = [NSString stringWithUTF8String:attributes];
    
    return [attr containsString:selfClassName];
}

#pragma mark - JSON handler helpers

+ (NSArray *) handlerJSONArray:(NSArray *)array
{
    DEBUG_ASSERTS_VALID([NSArray class], array);
    NSMutableArray *mObjs = [NSMutableArray new];
    for (NSDictionary *dict in array)
    {
        [mObjs addObject:[self coreObjectFromDictionary:dict]];
    }
    
    return [mObjs copy];
}

+ (NSArray *) handlerArrayToJSON:(NSArray *)array
{
    DEBUG_ASSERTS_VALID([NSArray class], array);
    NSMutableArray *mutable = [[NSMutableArray alloc] init];
    for (id obj in array)
    {
        NSDictionary *json = [obj coreToJSON];
        
        if (!json)
        {
            continue;
        }

        [mutable addObject:json];
    }
    return [mutable copy];
}

#pragma mark - CoreJSONSerializing protocol methods

+ (NSDictionary *_Nonnull) coreInputJSONKeyByPropertyKey
{
    return @{};
}

+ (NSDictionary *_Nonnull) coreOutputJSONKeyByPropertyKey
{
    return @{};
}

+ (NSDictionary *_Nonnull) coreRelationshipPropertyKey
{
    return @{};
}

+ (NSDictionary *)coreAPNSKeyByPropertyKey
{
    return @{};
}

- (NSArray<NSString *> *)coreOutputIgnoringJSONKeys
{
    return @[];
}

+ (CoreJSONDateFormmaterType) coreOutputJSONDateType
{
    return CoreJSONDateFormmaterType_String;
}


@end

@implementation NSArray(CoreSerializer)

- (NSArray<NSDictionary *> *)coreToJSON
{
    NSMutableArray *mArray = [NSMutableArray new];
    
    for (id obj in self)
    {
        if (![obj conformsToProtocol:@protocol(CoreJSONSerializing)])
        {
            continue;
        }
        
        NSDictionary *json = [obj coreToJSON];
        
        if (!json)
        {
            continue;
        }
        
        [mArray addObject:json];
    }
    
    return [mArray copy];
}

@end
