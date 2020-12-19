//
//  CDQCoreDataConfiguration.h
//  CDQCoreData
//
//  Created by Administrator on 19.12.2020.
//

#import <Foundation/Foundation.h>
#import "CDQCoreDataStorageConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDQCoreDataConfiguration : NSObject

@property (nonatomic, strong) CDQCoreDataStorageConfiguration *storageConfiguration;

@end

NS_ASSUME_NONNULL_END
