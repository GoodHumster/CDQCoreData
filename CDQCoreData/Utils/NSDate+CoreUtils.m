//
//  NSDate+CoreUtils.m
//  CDQCoreData
//
//  Created by Наиль  on 19.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDate+CoreUtils.h"
#import "NSString+CoreUtils.h"
#import "NSObject+CoreUtils.h"

#import "DebugAsserts.h"


@implementation NSDate(CoreUtils)

#pragma mark - Publick API methods

+ (NSDate *) coreDateFromUndefinedObject:(id)obj
{
    if (!obj)
    {
        return nil;
    }
    
    
    if ([obj isKindOfClass:[NSString class]])
    {
        static NSDateFormatter *dateFormmater = nil;
        static NSCharacterSet *charectrSet = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormmater = [[NSDateFormatter alloc] init];
            dateFormmater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            
            charectrSet = [NSCharacterSet letterCharacterSet];
        });
        
        NSString *dateString = [obj coreAsClass:[NSString class]];
        
        if (!dateString)
        {
            return nil;
        }
        
        dateString = [dateString stringByTrimmingCharactersInSet:charectrSet];
        
        BOOL hasT = [dateString coreIsHasString:@"'T'"] || [dateString coreIsHasString:@"T"];
        BOOL hasMileSeconds = NO;
        BOOL hasTimeZone = NO;
        
        if (dateString.length > 19)
        {
            NSString *tailDateString = [dateString substringFromIndex:19];
            NSRange rangeTimeZone = [tailDateString rangeOfString:@"+"];
            
            hasMileSeconds = [[tailDateString substringToIndex:1] isEqualToString:@"."];
            if (rangeTimeZone.length != NSNotFound && rangeTimeZone.location != NSNotFound)
            {
                hasTimeZone = [tailDateString substringFromIndex:rangeTimeZone.location+1].length >=4;
            }
         }
        
        NSArray *formatList = [self avaibleFormatLists];
        
        for (NSString *format in formatList)
        {
            BOOL formatHasT = [format coreIsHasString:@"'T'"];
            BOOL formatHasSSS = [format coreIsHasString:@"SSS"];
            BOOL formatHasZ = [format coreIsHasString:@"Z"];
            
            if (formatHasT != hasT || formatHasSSS != hasMileSeconds || formatHasZ != hasTimeZone)
            {
                continue;
            }
            
            dateFormmater.dateFormat = format;
            
            NSDate *date = [dateFormmater dateFromString:dateString];
            
            if (date)
            {
//                if (formatHasZ) {
//                    date =[[NSDate alloc] initWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:date];
//                }
                
                return date;
            }
        }
        
        return nil;
    }
    
    if ([obj isKindOfClass:[NSNumber class]])
    {
        return [self coreDateFromTimeInterval:[obj floatValue]];
    }
    
    return nil;
}

+ (NSDate *) coreDateFromString:(NSString *)str
{
    return [self coreDateFromString:str withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
}

+ (NSDate *) coreDateFromTimeInterval:(NSInteger)timeInterval
{
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

+ (NSDate *) coreDateFromString:(NSString *)str withFormat:(NSString *)format
{
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    dateFormmater.dateFormat = format;
    dateFormmater.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    return [dateFormmater dateFromString:str];
}

+ (NSString *) coreStringFromTimeInterval:(NSTimeInterval)interval inFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    dateFormmater.dateFormat = format;
    dateFormmater.timeZone = timeZone;
    
    return [dateFormmater stringFromDate:date];
}

- (NSString *) coreStringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    dateFormmater.dateFormat = format;
    dateFormmater.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    return [dateFormmater stringFromDate:self];
}

- (NSString *)coreMonthString
{
    NSDateFormatter *dateFrommater = [[NSDateFormatter alloc] init];
    dateFrommater.dateFormat = @"MMMM";
    
    return [dateFrommater stringFromDate:self];
}

- (NSString *) coreShortMonthString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
    dateFormatter.dateFormat = @"LLL";
    
    return [dateFormatter stringFromDate:self];
}

- (NSInteger) coreMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:self];
    
    return dateComp.month;
}

- (NSInteger) coreYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:self];
    
    return dateComp.year;
}

- (NSInteger) coreDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:self];
    
    return dateComp.day;
}

- (NSInteger)coreMultMonthByYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:self];
    
    return dateComp.month * dateComp.year;
}

- (NSDate *) coreStartDateCurrentMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond fromDate:self];
    dateComp.day = 1;
    dateComp.hour = 0;
    dateComp.minute = 0;
    dateComp.second = 1;

    return [calendar dateFromComponents:dateComp];
}

- (NSDate *) dateByAddingMonths:(NSInteger)monthsToAdd
{
    NSCalendar * calendar = [NSCalendar currentCalendar];

    NSDateComponents * months = [[NSDateComponents alloc] init];
    [months setMonth: monthsToAdd];

    return [calendar dateByAddingComponents: months toDate: self options: 0];
}

- (NSDate *) endOfMonth
{
    NSCalendar * calendar = [NSCalendar currentCalendar];

    NSDate * plusOneMonthDate = [self dateByAddingMonths: 1];
    NSDateComponents * plusOneMonthDateComponents = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth fromDate: plusOneMonthDate];
    NSDate * endOfMonth = [[calendar dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval: -1]; // One second before the start of next month

    return endOfMonth;
}

- (NSDate *) coreDateDeductMonth:(NSInteger)month
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:self];
    dateComp.month -= month;
    
    return [calendar dateFromComponents:dateComp];
}

- (BOOL) isLessOrEqualDate:(NSDate *)date
{
    NSTimeInterval selfInterval = [self timeIntervalSince1970];
    NSTimeInterval otherInterval = [date timeIntervalSince1970];
    
    return selfInterval <= otherInterval;
}


- (BOOL) isGreatOrEqualDate:(NSDate *)date
{
    NSTimeInterval selfInterval = [self timeIntervalSince1970];
    NSTimeInterval otherInterval = [date timeIntervalSince1970];
    
    return selfInterval >= otherInterval;
}

+ (NSArray<NSString *> *) coreLastSixMonthNameSinceNow
{
    NSDate *date = [NSDate date];
    NSMutableArray *months = [NSMutableArray new];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond fromDate:date];
    
    while (months.count < 6)
    {
        NSDate *date = [calendar dateFromComponents:comps];
        [months addObject:[date coreShortMonthString]];
        comps.month -= 1;
    }
    
    return [months copy];
}

- (BOOL) coreIsToday
{
    NSInteger separator = 60*60*24;
    return fabs([self timeIntervalSinceDate:[NSDate date]]) <= separator ;
}

- (BOOL)coreIsSameDayDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *selfComp = [calendar  components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:self];
    NSDateComponents *otherComp = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:date];
    
    return selfComp.month == otherComp.month && selfComp.day == otherComp.day && selfComp.year == otherComp.year;
}

+ (NSDate *)coreEndMonthDateOfCurrentDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond fromDate:[NSDate date]];
    dateComp.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateComp.day = 0;
    dateComp.hour = 0;
    dateComp.minute = 0;
    dateComp.second = 1;
    dateComp.month += 1;
    dateComp.day -= 1;

    return [calendar dateFromComponents:dateComp];
}

#pragma mark - utils methods

+ (NSArray *) avaibleFormatLists
{
    return @[
             @"dd.MM.yyyy",
             @"yyyy-MM-dd",
             @"yyyy-MM-dd'T'HH:mm:ss",
             @"yyyy-MM-dd'T'HH:mm:ss.SSS",
             @"yyyy-MM-dd'T'HH:mm:ssZ",
             @"yyyy-MM-dd'T'HH:mm:ss.SSSZ",
             @"yyyy-MM-dd HH:mm:ss.SSS",
             @"yyyy-MM-dd HH:mm:ss.SSSZ",
             @"yyyy-MM-dd HH:mm:ss",
             @"yyyy-MM-dd HH:mm:ssZ",
             @"yyyy-MM-dd HH:mm:ssZzzz"];
}

@end
