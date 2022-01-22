//
//  DriverViolationHeader+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverViolationHeader+CoreDataProperties.h"

@implementation DriverViolationHeader (CoreDataProperties)

+ (NSFetchRequest<DriverViolationHeader *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DriverViolationHeader"];
}

@dynamic socialSercurityNumber;
@dynamic employmentDate;
@dynamic terminalCity;
@dynamic terminalState;
@dynamic violationsthisyear;
@dynamic carrierName;
@dynamic carrierAddress;
@dynamic reviewedBy;
@dynamic reviewedDate;
@dynamic title;

@end
