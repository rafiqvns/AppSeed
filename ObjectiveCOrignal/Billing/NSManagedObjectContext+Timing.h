//
//  NSManagedObjectContext+Timing.h
//  MobileOffice
//
//  Created by .R.H. on 2/4/14.
//  Copyright (c) 2014 RCO. All rights reserved.
//

#import <CoreData/CoreData.h>

#define DATABASE_ACCESS_TIMING DEBUG
#define DATABASE_SAVE_TIMING DEBUG

#if DATABASE_ACCESS_TIMING
#define DATABASE_ACCESS_TIMING_ARGS  calledFrom:NSStringFromSelector(_cmd)
#else
#define DATABASE_ACCESS_TIMING_ARGS
#endif

#if DATABASE_ACCESS_TIMING
@interface NSManagedObjectContext (Timing)
- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError **)error calledFrom: (NSString *) callingMethod;
- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request error:(NSError **)error calledFrom: (NSString *) callingMethod;

@end

@interface NSFetchedResultsController (Timing)

- (BOOL)performFetch:(NSError **)error calledFrom: (NSString *) callingMethod;

@end
#endif
