//
//  CoreFormatterStorage.m
//  CreditCalendar
//
//  Created by Administrator on 28/10/2019.
//  Copyright © 2019 Alef. All rights reserved.
//

#import "CoreFormatterStorage.h"

#import "NSString+CoreUtils.h"

@interface CoreFormatterStorage()

@property (nonatomic, strong) NSCache<NSString *, id> *cache;

@end

@implementation CoreFormatterStorage

#pragma mark - init methods

- (instancetype) init
{
    if ( ( self = [super init]) == nil )
    {
        return nil;
    }
    self.cache = [[NSCache alloc] init];
    return self;
}

#pragma mark - Public API methods

- (NSNumberFormatter *)getCurrencyNumberFormatterForKey:(NSString *)key
{
    if ([self.cache objectForKey:key])
    {
        return [self.cache objectForKey:key];
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"ru_RU"];

    
    [self.cache setObject:numberFormatter forKey:key];
    return numberFormatter;
}

- (NSDateFormatter *)getDateFormatterUTCTimeZoneWithFormat:(NSString *)format
{
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    return [self getDateFormatterWithTimeZone:timeZone forFormat:format];
}

- (NSDateFormatter *)getDateFormatterSystemTimeZoneWithFormat:(NSString *)format
{
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    return [self getDateFormatterWithTimeZone:systemTimeZone forFormat:format];
}
        
#pragma mark - utils methods
        
- (NSDateFormatter *)getDateFormatterWithTimeZone:(NSTimeZone *)timeZone forFormat:(NSString *)format
{
    NSString *key = [self generateDateFormatterKeyWithTimeZone:timeZone andFormat:format];
    NSDateFormatter *dateFormatter = [self.cache objectForKey:key];
    
    if (dateFormatter)
    {
        return dateFormatter;
    }
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = timeZone;
    dateFormatter.dateFormat = format;
    
    [self.cache setObject:dateFormatter forKey:key];
    
    return dateFormatter;
}

- (NSString *) generateDateFormatterKeyWithTimeZone:(NSTimeZone *)timeZone andFormat:(NSString *)format
{
    NSString *nameTimeZone = timeZone.name;
    NSString *key = [NSString stringWithFormat:@"%@-%@",nameTimeZone,format];
    
    return [key coreToSHA1Hex];
}

@end
