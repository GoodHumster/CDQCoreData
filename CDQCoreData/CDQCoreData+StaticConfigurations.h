//
//  DatabaseManager+StaticConfigurations.h
//  CDQCoreData
//
//  Created by Administrator on 29/10/2019.
//  Copyright © 2019 Alef. All rights reserved.
//

#import "CDQCoreData.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDQCoreData (StaticConfigurations)

+ (NSArray *)getClassesNeedRemovedForVersion:(NSString *)version;

@end

NS_ASSUME_NONNULL_END
