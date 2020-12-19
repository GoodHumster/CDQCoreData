//
//  NSPropertyDescription+CoreUtils.m
//  CDQCoreData
//
//  Created by Administrator on 30/11/2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import "NSPropertyDescription+CoreUtils.h"

@implementation NSPropertyDescription (CoreUtils)

- (SEL)nameSelectorGetter
{
    NSString *inversetSetter = [NSString stringWithFormat:@"get%@:",[self.name capitalizedString]];
    SEL inversSelector = NSSelectorFromString(inversetSetter);
    
    return inversSelector;
}

- (SEL)nameSelectorSetter
{
    NSString *inversetSetter = [NSString stringWithFormat:@"set%@:",[self.name capitalizedString]];
    SEL inversSelector = NSSelectorFromString(inversetSetter);
    
    return inversSelector;
}

@end
