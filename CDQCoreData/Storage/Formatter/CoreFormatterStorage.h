//
//  CoreFormatterStorage.h
//  CreditCalendar
//
//  Created by Administrator on 28/10/2019.
//  Copyright © 2019 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreFormatterStorage : NSObject

- (NSDateFormatter *) getDateFormatterUTCTimeZoneWithFormat:(NSString *)format;
- (NSDateFormatter *) getDateFormatterSystemTimeZoneWithFormat:(NSString *)format;

- (NSNumberFormatter *)getCurrencyNumberFormatterForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
