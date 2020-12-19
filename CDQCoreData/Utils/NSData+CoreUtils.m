//
//  NSData+CoreUtils.m
//  CDQCoreData
//
//  Created by Наиль  on 21.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+CoreUtils.h"

#import "DebugAsserts.h"

@implementation NSData(CoreUtils)

#pragma mark - Publick API methods

+ (id) coreDataWithUndefinedObject:(id)object
{
    if (!object)
    {
        return nil;
    }
    
    if ([object isKindOfClass:[NSDictionary class]])
    {
        return [NSJSONSerialization dataWithJSONObject:object options:1 error:nil];
    }
    
    if ([object isKindOfClass:[NSArray class]])
    {
        return [NSJSONSerialization dataWithJSONObject:object options:1 error:nil];
    }
    
    if ([object isKindOfClass:[NSNumber class]] || [object conformsToProtocol:@protocol(NSCoding)])
    {
        return [self coreDataFromObject:object];
    }
    
    if ([object isKindOfClass:[NSString class]])
    {
        return [self coreDataFromString:object];
    }
    
    return nil;
}

- (NSArray *) coreDataParts
{
    NSInteger count = self.length / 32000;
    
    NSInteger lenght = 32000;
    NSInteger offset = 0;
    NSMutableArray *mArray = [NSMutableArray new];
    
    for (NSInteger i = 0; i<count; i++)
    {
        if (self.length - offset < lenght )
        {
            lenght = self.length - offset;
        }
        
        NSData *subData = [self subdataWithRange:NSMakeRange(offset, lenght)];
        [mArray addObject:subData];
        offset += lenght;
    }
    
    return mArray;
}

#pragma mark - utils methods

+ (id) coreDataFromString:(NSString *)string
{
    DEBUG_ASSERTS_VALID([NSString class], string);
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (id) coreDataFromObject:(NSObject<NSCoding> *)obj
{
    DEBUG_ASSERTS_VALID_PROTOCOL(NSCoding, obj);
    
    return [NSKeyedArchiver archivedDataWithRootObject:obj];
}

@end
