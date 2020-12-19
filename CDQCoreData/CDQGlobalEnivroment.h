//
//  CCGlobal.h
//  CreditCalendar
//
//  Created by Administrator on 28/10/2019.
//  Copyright © 2019 Alef. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreFormatterStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDQGlobalEnivroment : NSObject

@property (nonatomic, strong, readonly) CoreFormatterStorage *formatters;

@end

NS_ASSUME_NONNULL_END

extern const CDQGlobalEnivroment * _Nonnull globalEnviroments;
