//
//  NSString+CoreUtils.m
//  CDQCoreData
//
//  Created by Наиль  on 05.09.17.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>

#import "NSString+CoreUtils.h"
#import "DebugAsserts.h"

@implementation NSString(CoreUtils)

- (BOOL)isContainCharectersForLocale:(NSLocale *)locale
{
    NSCharacterSet *characters = locale.exemplarCharacterSet;
    NSRange range = [self rangeOfCharacterFromSet:characters];
    
    return range.location != NSNotFound;
}

- (BOOL) isEqualToUTF8String:(const char *)str
{
    if (str == NULL)
    {
        return NO;
    }
    
    NSString *other = [NSString stringWithUTF8String:str];
    DEBUG_ASSERTS_VALID([NSString class], other);
    
    return [self isEqualToString:other];
}

- (BOOL) coreIsHasString:(NSString *)str
{
    NSRange range = [self rangeOfString:str];
    
    return range.length != NSNotFound && range.location != NSNotFound;
}

- (BOOL) isEmailValid {
    NSString *validString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",validString];
    return [emailTest evaluateWithObject:self];
}


- (NSString *) coreToSHA1Hex
{
    NSData *data = [self coreToSHA1];
    
    if (!data)
    {
        return nil;
    }
    
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


- (NSData *) coreToSHA1
{
    const char *ptr = [self UTF8String];
    uint32_t size = (uint32_t)self.length;
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    if ( !CC_SHA1(ptr, size, digest))
    {
        return nil;
    }

   // digest = '\0';
//    NSMutableData *mData = [NSMutableData dataWithLength:size];
//    memcpy(mData.mutableBytes, digest, size);
//    return [mData copy];
    return [NSData dataWithBytes:digest length:size];
}

+ (NSString *)coreHexadecimalStringFromData:(NSData *)data
{
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
       return nil;
    }
     
    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
       [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];  
}

+ (NSString *) coreYearSerializationStringFromNumber:(NSInteger)number
{
    NSString *suffix = number >= 5 ? @"лет" : @"год";
    return [NSString stringWithFormat:@"%ld %@",(long)number,suffix];
}

+ (NSString *) coreMonthSerializedStringFromNumber:(NSInteger)number
{
    NSString *suffix = number >= 5 ? @"месяцев" : @"месяц";
    return [NSString stringWithFormat:@"%ld %@",(long)number,suffix];
}

- (NSString *) coreCapitalizedSimplePhraseString
{
    NSMutableArray *words = [[[self lowercaseString] componentsSeparatedByString:@" "] mutableCopy];
    
    if (words.count < 3)
    {
        return [self capitalizedString];
    }
    
    NSString *word = [words objectAtIndex:1];
    word = [word capitalizedString];
    [words replaceObjectAtIndex:1 withObject:word];
    
    return [words componentsJoinedByString:@" "];
}

- (NSRange)coreDetectUrlStringRange
{
    NSError *error = nil;
    NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    if (!dataDetector || error)
    {
        return NSMakeRange(NSNotFound, NSNotFound);
    }
    
    return [dataDetector rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)]; 
}

@end
