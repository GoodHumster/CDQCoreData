//
//  NSManagedObjectContext+CoreUtils.h
//  CDQCoreData
//
//  Created by Наиль  on 28.02.2018.
//  Copyright © 2018 Alef. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (CoreUtils)

/**
 * Special insert methods, which may insert single object or multiplie objects.
 */
- (void) coreInsert:(id)records;

@end
