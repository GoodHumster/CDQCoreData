//
//  CCGlobal.m
//  CreditCalendar
//
//  Created by Administrator on 28/10/2019.
//  Copyright © 2019 Alef. All rights reserved.
//

#import "CDQGlobalEnivroment.h"
#import "NSObject+CoreStaticConfiguration.h"

const CDQGlobalEnivroment * globalEnviroments = nil;

@implementation CDQGlobalEnivroment

+ (void)load
{
   if (!globalEnviroments)
   {
       globalEnviroments = [[CDQGlobalEnivroment alloc] init];
   }
}

- (instancetype) init
{
    if ( ( self = [super init]) == nil )
    {
        return nil;
    }
     
    _formatters = [[CoreFormatterStorage alloc] init];
    
    return self;
}

@end
