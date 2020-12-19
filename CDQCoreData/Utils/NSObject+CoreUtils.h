//
//  NSObject+CoreUtils.h
//  CDQCoreData
//
//  Created by Наиль  on 29.08.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSObject_CoreUtils <NSObject>


- (id) coreAsClass:(Class)cls;

- (id) coreAsProtocol:(Protocol *)protocol;

+ (NSString*)coreBundleIdentifierForClass:(Class)cls;

+ (BOOL) isKindOfClass:(Class)cls;

- (NSInteger) coreIntegerValue;

- (BOOL)coreBoolValue;

- (double) coreDoubleValue;

- (float) coreFloatValue;

- (NSString *) coreStringValue;

- (NSData *) coreData;

- (NSNumber *) coreNumber;

- (NSSet *) coreSet;

@end

@interface NSObject(CoreUtils)<NSObject_CoreUtils>

- (BOOL) coreIsNull;

@end
