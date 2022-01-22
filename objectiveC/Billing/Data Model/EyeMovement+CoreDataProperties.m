//
//  EyeMovement+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 12/12/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "EyeMovement+CoreDataProperties.h"

@implementation EyeMovement (CoreDataProperties)

+ (NSFetchRequest<EyeMovement *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"EyeMovement"];
}

@dynamic company;
@dynamic driverLicenseNumber;
@dynamic driverLicenseState;
@dynamic eyeMovement;
@dynamic finishDateTime;
@dynamic frontCounter;
@dynamic instructorEmployeeId;
@dynamic instructorFirstName;
@dynamic instructorLastName;
@dynamic leftMirrorCounter;
@dynamic masterMobileRecordId;
@dynamic rearCounter;
@dynamic rightMirrorCounter;
@dynamic startTimes;
@dynamic stopTimes;
@dynamic studentEmployeeId;
@dynamic studentFirstName;
@dynamic studentLastName;
@dynamic eyeLeadCounter;
@dynamic followTimeCounter;
@dynamic gaugesCounter;
@dynamic intersectionsCounter;
@dynamic parkedCarsCounter;
@dynamic pedestriansCounter;

@end
