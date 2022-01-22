//
//  TestDataHeader+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/3/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "TestDataHeader+CoreDataProperties.h"

@implementation TestDataHeader (CoreDataProperties)

+ (NSFetchRequest<TestDataHeader *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TestDataHeader"];
}

@dynamic company;
@dynamic correctiveLensRequired;
@dynamic department;
@dynamic disqualifiedRemarks;
@dynamic dotExpirationDate;
@dynamic dotNumber;
@dynamic driverHistoryReviewed;
@dynamic driverLicenseClass;
@dynamic driverLicenseExpirationDate;
@dynamic driverLicenseNumber;
@dynamic driverLicenseState;
@dynamic driverName;
@dynamic elapsedTime;
@dynamic employeeId;
@dynamic employeeRecordId;
@dynamic endDateTime;
@dynamic endorsements;
@dynamic equipmentClean;
@dynamic equipmentReady;
@dynamic evaluatorName;
@dynamic evaluatorTitle;
@dynamic finishOdometer;
@dynamic instructorEmployeeId;
@dynamic instructorFirstName;
@dynamic instructorLastName;
@dynamic keysReady;
@dynamic location;
@dynamic medicalCardExpirationDate;
@dynamic miles;
@dynamic numberofTrailers;
@dynamic onTime;
@dynamic pauseDateTimes;
@dynamic pointsPossible;
@dynamic pointsReceived;
@dynamic powerUnit;
@dynamic qualifiedYesNo;
@dynamic restrictions;
@dynamic routeNumber;
@dynamic startDateTime;
@dynamic startOdometer;
@dynamic studentFirstName;
@dynamic studentLastName;
@dynamic testDate;
@dynamic testMiles;
@dynamic testRemarks;
@dynamic testResult;
@dynamic testState;
@dynamic timecardSystemReady;
@dynamic trailerLength;
@dynamic observerFirstName;
@dynamic observerLastName;

@end
