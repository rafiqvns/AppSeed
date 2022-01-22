//
//  TrainingScore+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 12/27/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingScore+CoreDataProperties.h"

@implementation TrainingScore (CoreDataProperties)

+ (NSFetchRequest<TrainingScore *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TrainingScore"];
}

@dynamic company;
@dynamic studentFirstName;
@dynamic studentLastName;
@dynamic driverLicenseNumber;
@dynamic driverLicenseState;
@dynamic instructorFirstName;
@dynamic employeeId;
@dynamic instructorLastName;
@dynamic instructorEmployeeId;
@dynamic testName;
@dynamic sectionName;
@dynamic elapsedTime;
@dynamic pointsReceived;
@dynamic pointsPossible;
@dynamic masterMobileRecordId;

@end
