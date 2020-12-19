//
//  CDQCoreDataStorageConfiguration.h
//  CDQCoreData
//
//  Created by Administrator on 19.12.2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDQCoreDataStorageConfiguration : NSObject

@property (nonatomic, strong) NSString *storagePath;
@property (nonatomic, assign) BOOL shouldWipeDatabaseOnNewVersion;

@end

NS_ASSUME_NONNULL_END
