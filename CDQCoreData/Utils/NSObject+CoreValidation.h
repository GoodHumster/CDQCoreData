//
//  NSObject+CoreValidation.h
//  CDQCoreData
//
//  Created by Наиль  on 16.10.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(CoreValidation)

- (BOOL) coreValidateValue:(id * _Nonnull)value forKey:(NSString * _Nonnull)key;

- (BOOL) coreIsKindOfClass:(Class _Nonnull)cls forKey:(NSString * _Nonnull)key;

@end
