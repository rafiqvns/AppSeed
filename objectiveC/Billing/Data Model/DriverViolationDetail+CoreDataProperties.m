//
//  DriverViolationDetail+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverViolationDetail+CoreDataProperties.h"

@implementation DriverViolationDetail (CoreDataProperties)

+ (NSFetchRequest<DriverViolationDetail *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DriverViolationDetail"];
}

@dynamic violationOffense;
@dynamic violationLocation;
@dynamic violationtypeofvehicle;

@end
