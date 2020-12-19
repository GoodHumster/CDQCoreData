//
//  NSDate+CoreUtils.h
//  CDQCoreData
//
//  Created by Наиль  on 19.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

@interface NSDate(CoreUtils)

+ (NSDate *)coreEndMonthDateOfCurrentDate;

+ (NSDate *) coreDateFromString:(NSString *)str;

+ (NSDate *) coreDateFromTimeInterval:(NSInteger)timeInterval;

+ (NSDate *) coreDateFromUndefinedObject:(id)obj;

+ (NSDate *) coreDateFromString:(NSString *)str withFormat:(NSString *)format;

- (NSDate *) coreDateDeductMonth:(NSInteger)month;

- (NSDate *) coreStartDateCurrentMonth;

- (NSDate *) dateByAddingMonths:(NSInteger)monthsToAdd;

- (NSDate *) endOfMonth;


+ (NSString *) coreStringFromTimeInterval:(NSTimeInterval)interval inFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone;

- (NSString *) coreStringWithFormat:(NSString *)format;

- (NSString *) coreMonthString;

- (NSString *) coreShortMonthString;

+ (NSArray<NSString *> *) coreLastSixMonthNameSinceNow;

- (NSInteger) coreMonth;

- (NSInteger) coreDay;

- (NSInteger) coreYear;

- (NSInteger) coreMultMonthByYear;

- (BOOL) coreIsToday;

- (BOOL) isLessOrEqualDate:(NSDate *)date;

- (BOOL) isGreatOrEqualDate:(NSDate *)date;

- (BOOL) coreIsSameDayDate:(NSDate *)date;

@end
