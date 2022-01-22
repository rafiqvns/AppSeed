//
//  AccidentVehicleReport+CoreDataProperties.m
//  MobileOffice
//
//  Created by .D. .D. on 6/20/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentVehicleReport+CoreDataProperties.h"

@implementation AccidentVehicleReport (CoreDataProperties)

+ (NSFetchRequest<AccidentVehicleReport *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AccidentVehicleReport"];
}

@dynamic accidentChargeableDetermination;
@dynamic accidentCrashType;
@dynamic accidentDegree;
@dynamic accidentDescription;
@dynamic accidentIncidentDescription;
@dynamic accidentIncidentType;
@dynamic accidentInjuryOccurred;
@dynamic accidentLocationSecured;
@dynamic accidentSeverityLevel;
@dynamic accidentSiteDescription;
@dynamic ambulanceOnSite;
@dynamic annualSafetyReview;
@dynamic anotherViehicleInvolved;
@dynamic anyoneElseInjured;
@dynamic coronerOnSite;
@dynamic employeeAccidentHistory;
@dynamic employeesManagerWorkgroupSafetyHistory;
@dynamic employmentDate;
@dynamic fatilities;
@dynamic fireExtinguisherAvailable;
@dynamic fireExtinguisherUsed;
@dynamic fireonSite;
@dynamic followUpTraining;
@dynamic injured;
@dynamic injuryDegreeOthers;
@dynamic injuryDegreeYour;
@dynamic isFire;
@dynamic isThereASpill;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic mentorAssigned;
@dynamic numberOfInjuries;
@dynamic numberOfVehiclesInvolved;
@dynamic numberOfVehiclesTowed;
@dynamic otherVehicleNeedsTowing;
@dynamic paramedicsOnSite;
@dynamic policeOnSite;
@dynamic preventionActivity1ForEmployee;
@dynamic preventionActivity1ForWorkforce;
@dynamic preventionActivity2ForEmployee;
@dynamic preventionActivity2ForWorkforce;
@dynamic priorTraining;
@dynamic rootCause1;
@dynamic rootCause2;
@dynamic safetyReviewDate;
@dynamic sizeOfFire;
@dynamic spillContained;
@dynamic spillSize;
@dynamic spillType;
@dynamic transported;
@dynamic transportedToLocation;
@dynamic vehicleNeedsTowing;
@dynamic weatherConditions;
@dynamic workforceNotificationPosted;
@dynamic wasAccidentAvoidable;
@dynamic whoIsTheFault;

@end
