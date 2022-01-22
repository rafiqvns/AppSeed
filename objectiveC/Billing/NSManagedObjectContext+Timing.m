//
//  NSManagedObjectContext+Timing.m
//  MobileOffice
//
//  Created by .R.H. on 2/4/14.
//  Copyright (c) 2014 RCO. All rights reserved.
//

#import "NSManagedObjectContext+Timing.h"


@implementation NSManagedObjectContext (Timing)

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError **)error calledFrom: (NSString *) callingMethod
{
#if DATABASE_ACCESS_TIMING
    CFTimeInterval startTime = CACurrentMediaTime();
#endif
    //08.10.2018__block NSArray * returnArray = nil;
    NSArray * returnArray = nil;

    //08.10.2018[self performBlockAndWait:^{
        returnArray = [self executeFetchRequest:request error:error];
    //}];
    
#if DATABASE_ACCESS_TIMING
    CFTimeInterval fetchDuration =CACurrentMediaTime() - startTime;
    NSLog(@">>> %@ (%@) fetched %d obj in %.3f secs, %@ %@", callingMethod,request.entity.name, (int)[returnArray count], fetchDuration,
          (request.predicate == nil) ? @"" : request.predicate,
          (request.sortDescriptors == nil) ? @"" : request.sortDescriptors );
    
    if( fetchDuration > 1.0 && [NSThread currentThread] == [NSThread mainThread] ) {
        NSLog(@">>> *** WARNING - database access > 1 second on main thread *** <<<<" );
        
    }
#endif

    return returnArray;
}

- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request error:(NSError **)error calledFrom: (NSString *) callingMethod
{
#if DATABASE_ACCESS_TIMING
    CFTimeInterval startTime = CACurrentMediaTime();
#endif
    //08.10.2018__block NSUInteger count = 0;
    NSUInteger count = 0;

    //08.10.2018[self performBlockAndWait:^{
        count = [self countForFetchRequest:request error:error];
    //}];
    
#if DATABASE_ACCESS_TIMING
    CFTimeInterval fetchDuration =CACurrentMediaTime() - startTime;
    NSLog(@">>> %@ (%@) counted %d in %.3f secs, %@ %@", callingMethod,request.entity.name, (int)count, fetchDuration,
          (request.predicate == nil) ? @"" : request.predicate,
          (request.sortDescriptors == nil) ? @"" : request.sortDescriptors );

    if( fetchDuration > 1.0 && [NSThread currentThread] == [NSThread mainThread] ) {
        NSLog(@">>> *** WARNING - database access > 1 second on main thread *** <<<<" );
    }
#endif
    
    return count;
}

@end

@implementation NSFetchedResultsController (Timing)

- (BOOL)performFetch:(NSError **)error calledFrom: (NSString *) callingMethod
{
#if DATABASE_ACCESS_TIMING
    CFTimeInterval startTime = CACurrentMediaTime();
#endif
    BOOL bFetchSuccess = [self performFetch: (NSError **)error];
    
#if DATABASE_ACCESS_TIMING
    
    CFTimeInterval fetchDuration =CACurrentMediaTime() - startTime;
    NSFetchRequest *request = self.fetchRequest;
    
    NSLog(@">>> %@ (%@) fetched %d in %.3f secs, %@ %@", callingMethod, request.entity.name, (int)[self.fetchedObjects count], fetchDuration,
          (request.predicate == nil) ? @"" : request.predicate,
          (request.sortDescriptors == nil) ? @"" : request.sortDescriptors );
    
    if( fetchDuration > 1.0 && [NSThread currentThread] == [NSThread mainThread] ) {
        NSLog(@">>> *** WARNING - database access > 1 second on main thread *** <<<<" );
        
    }
#endif

    return bFetchSuccess;
}

@end
