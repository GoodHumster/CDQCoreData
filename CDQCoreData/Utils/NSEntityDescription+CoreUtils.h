//
//  NSEntityDescription+CoreUtils.h
//  CDQCoreData
//
//  Created by Administrator on 24/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSEntityDescription (CoreUtils)

@property (nonatomic, strong) NSDictionary *parentRelatonshipsByName;

@end

NS_ASSUME_NONNULL_END
