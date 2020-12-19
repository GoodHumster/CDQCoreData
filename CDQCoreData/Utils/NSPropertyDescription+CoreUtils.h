//
//  NSPropertyDescription+CoreUtils.h
//  CDQCoreData
//
//  Created by Administrator on 30/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPropertyDescription (CoreUtils)

- (SEL) nameSelectorSetter;

- (SEL) nameSelectorGetter;

@end

NS_ASSUME_NONNULL_END
