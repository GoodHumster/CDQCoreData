//
//  NSAttributeDescription+CoreUtils.h
//  CDQCoreData
//
//  Created by Administrator on 12/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributeDescription (CoreUtils)

- (NSPredicate *) corePridcateWithKey:(NSString *)key andArgument:(id)argument;

@end

NS_ASSUME_NONNULL_END
