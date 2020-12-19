//
//  CoreJSONSerializing.h
//  CDQCoreData
//
//  Created by Наиль  on 07.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CoreJSONDateFormmaterType)
{
    CoreJSONDateFormmaterType_String,
    CoreJSONDateFormmaterType_Unix
};

@protocol CoreJSONSerializing <NSObject>

@optional

+ (CoreJSONDateFormmaterType) coreOutputJSONDateType;

+ (NSDictionary *_Nonnull) coreInputJSONKeyByPropertyKey;

+ (NSDictionary *_Nonnull) coreOutputJSONKeyByPropertyKey;

+ (NSDictionary *_Nonnull) coreRelationshipPropertyKey;

+ (NSDictionary *_Nonnull) coreAPNSKeyByPropertyKey;

- (NSArray<NSString *> *_Nonnull) coreOutputIgnoringJSONKeys;

@end
