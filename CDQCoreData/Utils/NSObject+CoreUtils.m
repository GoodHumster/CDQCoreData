//
//  NSObject+CoreUtils.m
//  CDQCoreData
//
//  Created by Наиль  on 29.08.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+CoreUtils.h"

@implementation NSObject(CoreUtils)

- (id) coreAsClass:(Class)cls
{
    return [self isKindOfClass:cls] ? self : nil;
}

- (id) coreAsProtocol:(Protocol*)protocol
{
    return [self conformsToProtocol:protocol] ? self : nil;
}

- (NSInteger) coreIntegerValue
{
    if (!self)
    {
        return 0;
    }
    
    NSNumber *number = [self coreAsClass:[NSNumber class]];
    if( [self isKindOfClass:[NSString class]] )
    {
        NSNumberFormatter* nf = [[NSNumberFormatter alloc] init];
        number = [nf numberFromString:(NSString *)self];
        
        if (number == nil)
        {
            NSString *fromString = (NSString *)self;
            return [fromString integerValue];
        }
    }
    
    if ( [self isKindOfClass:[NSData class]])
    {
        NSData *data = [self coreAsClass:[NSData class]];
        NSString *nmStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (nmStr)
        {
            return [nmStr coreIntegerValue];
        }
        
        number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return [number integerValue];
}

- (NSNumber *) coreNumber
{
    if (!self)
    {
        return 0;
    }
    
    NSNumber *number = [self coreAsClass:[NSNumber class]];
    
    if (number)
    {
        return number;
    }
    
    if ([self isKindOfClass:[NSString class]])
    {
        NSNumberFormatter* nf = [[NSNumberFormatter alloc] init];
        number = [nf numberFromString:(NSString *)self];
    }
    
    if (number)
    {
        return number;
    }
    
    return nil;
}

- (BOOL) coreBoolValue
{
    if (!self)
    {
        return 0;
    }
    NSNumber *number = [self coreAsClass:[NSNumber class]];
    if( [self isKindOfClass:[NSString class]] )
    {
        NSNumberFormatter* nf = [[NSNumberFormatter alloc] init];
        number = [nf numberFromString:(NSString *)self];
        
        if (number == nil)
        {
            NSString *fromString = (NSString *)self;
            return [fromString boolValue];
        }
    }
    
    if ( [self isKindOfClass:[NSData class]])
    {
        NSData *data = [self coreAsClass:[NSData class]];
        NSString *nmStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (nmStr)
        {
            return [nmStr coreBoolValue];
        }
        
        number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    return [number boolValue];
}

- (double) coreDoubleValue
{
    if (!self)
    {
        return 0.0;
    }
    NSNumber *number = [self coreAsClass:[NSNumber class]];
    if( [self isKindOfClass:[NSString class]] )
    {
        NSString *fromString = (NSString *)self;
        return [fromString doubleValue];
    }
    
    if ( [self isKindOfClass:[NSData class]])
    {
        NSData *data = [self coreAsClass:[NSData class]];
        NSString *nmStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (nmStr)
        {
            return [nmStr doubleValue];
        }
        
        number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return [number doubleValue];
}

- (NSData *) coreData
{
    if (!self || [self isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    if ([self isKindOfClass:[NSData class]])
    {
        return [self coreAsClass:[NSData class]];
    }
    
    if ([self isKindOfClass:[NSNumber class]])
    {
        NSUInteger index = [self coreIntegerValue];
        return [NSData dataWithBytes:&index length:index];
    }
    return nil;
}

- (NSString *)coreStringValue
{
    if (!self || [self isKindOfClass:[NSNull class]] || self == nil)
    {
        return @"";
    }
    
    if ([self isKindOfClass:[NSData class]])
    {
        NSData *data = [self coreAsClass:[NSData class]];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (!str)
        {
            str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }
        
        return [str coreStringValue];
    }
    
    return (NSString *)self;
}

- (NSSet *) coreSet
{
    if (!self || [self isKindOfClass:[NSNull class]])
    {
        return [NSSet set];
    }
    
    if ([self isKindOfClass:[NSMutableSet class]])
    {
        return [[NSSet alloc] initWithSet:(NSSet *)self copyItems:NO];
    }
    
    if (![self coreAsClass:[NSSet class]])
    {
        return [NSSet set];
    }
    
    return (NSSet *)self;
}

+ (BOOL) isKindOfClass:(Class)cls
{
    return self == cls;
}

+ (NSString*)coreBundleIdentifierForClass:(Class)cls
{
    if( cls == nil )
    {
        cls = self;
    }
    
    NSBundle* bundle = [NSBundle bundleForClass:cls];
    NSString* bundleId = [bundle bundleIdentifier];
    if( bundleId != nil )
    {
        return bundleId;
    }
    
    bundle = [NSBundle mainBundle];
    return [bundle bundleIdentifier];
}

- (BOOL) coreIsNull
{
    return [self isKindOfClass:[NSNull class]];
}

- (float) coreFloatValue
{
    return (float)[self coreDoubleValue];
}

//- (NSArray *) attributesProperty:(objc_property_t)property
//{
//    const char *attr = property_getAttributes(property);
//    NSString *attrStr = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
//    NSArray *attributes = [attrStr componentsSeparatedByString:@","];
//    
//    return attributes;
//}


@end
