//
//  NSString+CoreUtils.h
//  CDQCoreData
//
//  Created by Наиль  on 05.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//


@interface NSString(CoreUtils)

- (BOOL) isEqualToUTF8String:(const char *)str;
- (BOOL) coreIsHasString:(NSString *)str;
- (BOOL) isEmailValid;
- (BOOL) isContainCharectersForLocale:(NSLocale *)locale;

- (NSString *) coreToSHA1Hex;
- (NSData *) coreToSHA1;

+ (NSString *) coreHexadecimalStringFromData:(NSData *)data;
+ (NSString *) coreYearSerializationStringFromNumber:(NSInteger)number;
+ (NSString *) coreMonthSerializedStringFromNumber:(NSInteger)number;
- (NSString *) coreCapitalizedSimplePhraseString;

- (NSRange) coreDetectUrlStringRange;



@end
