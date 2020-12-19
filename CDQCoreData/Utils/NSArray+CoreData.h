//
//  NSArray+CoreData.h
//  CDQCoreData
//
//  Created by Administrator on 01/12/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSRelationshipDescription;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (CoreData)

+ (NSArray *) coreRelationshipsArrayFromValue:(id)value;


@end

NS_ASSUME_NONNULL_END
