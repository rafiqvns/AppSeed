//
//  TrainingTestInfo+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 2/25/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "TrainingTestInfo+CoreDataProperties.h"

@implementation TrainingTestInfo (CoreDataProperties)

+ (NSFetchRequest<TrainingTestInfo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TrainingTestInfo"];
}

@dynamic comments;
@dynamic company;
@dynamic correctiveLensRequired;
@dynamic dotExpirationDate;
@dynamic driverHistoryReviewed;
@dynamic driverLicenseClass;
@dynamic driverLicenseExpirationDate;
@dynamic driverLicenseNumber;
@dynamic driverLicenseState;
@dynamic elapsedTime;
@dynamic employeeId;
@dynamic endDateTime;
@dynamic endorsements;
@dynamic equipmentType;
@dynamic evaluationLocation;
@dynamic groupName;
@dynamic groupNumber;
@dynamic instructorEmployeeId;
@dynamic instructorFirstName;
@dynamic instructorLastName;
@dynamic parentMobileRecordId;
@dynamic pauseDateTimes;
@dynamic pointsPossible;
@dynamic pointsReceived;
@dynamic powerUnit;
@dynamic restrictions;
@dynamic startDateTime;
@dynamic studentFirstName;
@dynamic studentLastName;
@dynamic trainingAccidentDate;
@dynamic trainingAnnual;
@dynamic trainingBehindTheWheel;
@dynamic trainingChangeJob;
@dynamic trainingChangeOfEquipment;
@dynamic trainingEquipment;
@dynamic trainingEye;
@dynamic trainingIncidentFollowUp;
@dynamic trainingInjuryDate;
@dynamic trainingLostTimeStartDate;
@dynamic trainingNearMiss;
@dynamic trainingNewHire;
@dynamic trainingPreTrip;
@dynamic trainingProd;
@dynamic trainingReturnToWorkDate;
@dynamic trainingSWP;
@dynamic trainingTAWEndDate;
@dynamic trainingTAWStartDate;
@dynamic trainingVRT;
@dynamic trainingPassengerEvacuation;
@dynamic trainingPassengerPreTrip;

@end
