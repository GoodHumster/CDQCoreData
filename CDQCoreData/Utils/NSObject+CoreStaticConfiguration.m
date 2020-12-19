
//
//  NSObject+CoreStaticConfiguration.m
//  CDQCoreData
//
//  Created by Наиль  on 07.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "NSObject+CoreStaticConfiguration.h"
#import "NSObject+CoreUtils.h"

@implementation NSObject(CoreStaticConfiguration)

+ (NSDictionary *) coreDeviceInfo
{
    NSMutableDictionary *deviceInfo = NSMutableDictionary.new;
    
    [deviceInfo addEntriesFromDictionary:@{@"type": @"phone",
                                           @"os": @"iOS",
                                           @"locale": NSLocale.currentLocale.localeIdentifier
                                           }];
    
    NSDateFormatter *dateFormatter = NSDateFormatter.new;
    dateFormatter.dateFormat = @"Z";
    NSString *timezone = [dateFormatter stringFromDate:NSDate.date];
    [deviceInfo setObject:timezone forKey:@"timezone"];
    
    return deviceInfo.copy;
}

+ (NSString*) coreStaticConfigurationLibraryBaseDirPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if( paths.count == 0 )
    {
        return nil;
    }
    
    NSString* baseDir = [[paths firstObject] stringByAppendingPathComponent:[self coreBundleIdentifierForClass:self]];
    
    return baseDir;
}

+ (NSString*)coreStaticConfigurationCacheBaseDirPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if( paths.count == 0 )
    {
        return nil;
    }
    
    NSString* cacheDir = [paths firstObject];
    cacheDir = [cacheDir stringByAppendingPathComponent:[self coreBundleIdentifierForClass:self]];
    
    return cacheDir;
}


+ (NSString *) coreStaticCoreDataFilePath
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"DataModel" ofType:@"momd"];
    
    return path;
}

+ (NSString *) coreStaticCoreDataMapFilePath
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"DataMappingModel" ofType:@"xcmappingmodel"];
    
    return path;
}

+ (NSString *) coreAppVersion
{
//    NSString *defaultBundleIdentifier = @"com.alef.CDQCoreData";
    NSString *defaultAppVersion = @"1.0.0";
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    if (!mainBundle)
    {
        return defaultAppVersion;
    }
    NSDictionary *infoDict = [mainBundle infoDictionary];
    if (!infoDict)
    {
        return defaultAppVersion;
    }
    NSString *version = [infoDict valueForKey:@"CFBundleShortVersionString"];
    if (!version)
    {
        return defaultAppVersion;
    }
    return version;
}

@end
