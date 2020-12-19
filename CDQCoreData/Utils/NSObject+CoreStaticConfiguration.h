
//
//  NSObject+CoreStaticConfiguration.h
//  CDQCoreData
//
//  Created by Наиль  on 07.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

@interface NSObject(CoreStaticConfiguration)

+ (NSDictionary *) coreDeviceInfo;

+ (NSString *) coreStaticConfigurationLibraryBaseDirPath;

+ (NSString *) coreStaticConfigurationCacheBaseDirPath;

+ (NSString *) coreStaticCoreDataFilePath;

+ (NSString *) coreStaticCoreDataMapFilePath;

+ (NSString *) coreAppVersion;

@end
