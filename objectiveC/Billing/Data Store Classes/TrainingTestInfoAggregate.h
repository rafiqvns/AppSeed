//
//  TrainingTestInfoAggregate.h
//  CSD
//
//  Created by .D. .D. on 11/7/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"

NS_ASSUME_NONNULL_BEGIN

#define CLAS @"CLAS"

@class TrainingTestInfo;

@interface TrainingTestInfoAggregate : Aggregate

-(NSArray*)getTestsForDriverLicenseNumbed:(NSString*)driverLicenseNumber andDriverLicenseState:(NSString*)driverLicenseState;
-(TrainingTestInfo*)getMostRecentTestForDriverLicenseNumber:(NSString*)driverLicenseNumber andDriverLicenseState:(NSString*)driverLicenseState;

@end

NS_ASSUME_NONNULL_END
