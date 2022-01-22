//
//  TrainingInstructor+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingInstructor+CoreDataProperties.h"

@implementation TrainingInstructor (CoreDataProperties)

+ (NSFetchRequest<TrainingInstructor *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TrainingInstructor"];
}

@dynamic company;
@dynamic correctiveLensRequired;
@dynamic dotExpirationDate1;
@dynamic driverLicenseExpirationDate;
@dynamic driverLicenseNumber;
@dynamic driverLicenseState;
@dynamic employeeId;
@dynamic endorsements;
@dynamic firstName;
@dynamic lastName;
@dynamic studentClass;
@dynamic instructorId;

@end
