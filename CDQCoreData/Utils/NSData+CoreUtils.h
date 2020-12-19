//
//  NSData+CoreUtils.h
//  CDQCoreData
//
//  Created by Наиль  on 21.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

@interface NSData(CoreUtils)

+ (id) coreDataWithUndefinedObject:(id)object;

- (NSArray *) coreDataParts;

@end
