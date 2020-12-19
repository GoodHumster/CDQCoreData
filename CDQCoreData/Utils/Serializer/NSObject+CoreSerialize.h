//
//  NSObject+CoreSerialize.h
//  CDQCoreData
//
//  Created by Наиль  on 07.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreJSONSerializing.h"

@protocol CoreSerializer <NSObject>

+ (id) coreObjectFromDictionary:(NSDictionary *)dict;

- (NSDictionary *) coreToJSON;

- (NSDictionary *) coreToAPNSNotificationJSON;


@end

@interface NSObject(CoreSerializer)<CoreSerializer,CoreJSONSerializing>

@end

@interface NSArray(CoreSerializer)<CoreSerializer>

- (NSArray<NSDictionary *> *)coreToJSON;

@end
