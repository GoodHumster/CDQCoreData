//
//  CoreFetchResultsController.h
//  CDQCoreData
//
//  Created by Наиль  on 28.11.2017.
//  Copyright © 2017 Alef. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef void (^CoreFetchedResultsControllerTrackingBlock) (NSArray *results,NSManagedObjectContext *context);

@interface CoreFetchedResultsController : NSFetchedResultsController

@property (nonatomic, strong, readonly) NSString *keyPath;
@property (nonatomic, assign, readonly) Class coreDataObjectClass;
@property (nonatomic, strong) CoreFetchedResultsControllerTrackingBlock trakingBlock;


+ (id) controllerWithCoreDataObjectClass:(Class)cls withFetchedBlock:(CoreFetchedResultsControllerTrackingBlock)trakingBlock;

+ (id) controllerWithRequest:(NSFetchRequest *)request withTrackingBlock:(CoreFetchedResultsControllerTrackingBlock)trackingBlock;


@end
