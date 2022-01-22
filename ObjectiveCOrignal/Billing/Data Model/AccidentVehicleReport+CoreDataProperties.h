//
//  AccidentVehicleReport+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 6/20/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentVehicleReport+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AccidentVehicleReport (CoreDataProperties)

+ (NSFetchRequest<AccidentVehicleReport *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *accidentChargeableDetermination;
@property (nullable, nonatomic, copy) NSString *accidentCrashType;
@property (nullable, nonatomic, copy) NSString *accidentDegree;
@property (nullable, nonatomic, copy) NSString *accidentDescription;
@property (nullable, nonatomic, copy) NSString *accidentIncidentDescription;
@property (nullable, nonatomic, copy) NSString *accidentIncidentType;
@property (nullable, nonatomic, copy) NSString *accidentInjuryOccurred;
@property (nullable, nonatomic, copy) NSString *accidentLocationSecured;
@property (nullable, nonatomic, copy) NSString *accidentSeverityLevel;
@property (nullable, nonatomic, copy) NSString *accidentSiteDescription;
@property (nullable, nonatomic, copy) NSString *ambulanceOnSite;
@property (nullable, nonatomic, copy) NSString *annualSafetyReview;
@property (nullable, nonatomic, copy) NSString *anotherViehicleInvolved;
@property (nullable, nonatomic, copy) NSString *anyoneElseInjured;
@property (nullable, nonatomic, copy) NSString *coronerOnSite;
@property (nullable, nonatomic, copy) NSString *employeeAccidentHistory;
@property (nullable, nonatomic, copy) NSString *employeesManagerWorkgroupSafetyHistory;
@property (nullable, nonatomic, copy) NSDate *employmentDate;
@property (nullable, nonatomic, copy) NSString *fatilities;
@property (nullable, nonatomic, copy) NSString *fireExtinguisherAvailable;
@property (nullable, nonatomic, copy) NSString *fireExtinguisherUsed;
@property (nullable, nonatomic, copy) NSString *fireonSite;
@property (nullable, nonatomic, copy) NSString *followUpTraining;
@property (nullable, nonatomic, copy) NSString *injured;
@property (nullable, nonatomic, copy) NSString *injuryDegreeOthers;
@property (nullable, nonatomic, copy) NSString *injuryDegreeYour;
@property (nullable, nonatomic, copy) NSString *isFire;
@property (nullable, nonatomic, copy) NSString *isThereASpill;
@property (nullable, nonatomic, copy) NSString *latitude;
@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, copy) NSString *longitude;
@property (nullable, nonatomic, copy) NSString *mentorAssigned;
@property (nullable, nonatomic, copy) NSString *numberOfInjuries;
@property (nullable, nonatomic, copy) NSString *numberOfVehiclesInvolved;
@property (nullable, nonatomic, copy) NSString *numberOfVehiclesTowed;
@property (nullable, nonatomic, copy) NSString *otherVehicleNeedsTowing;
@property (nullable, nonatomic, copy) NSString *paramedicsOnSite;
@property (nullable, nonatomic, copy) NSString *policeOnSite;
@property (nullable, nonatomic, copy) NSString *preventionActivity1ForEmployee;
@property (nullable, nonatomic, copy) NSString *preventionActivity1ForWorkforce;
@property (nullable, nonatomic, copy) NSString *preventionActivity2ForEmployee;
@property (nullable, nonatomic, copy) NSString *preventionActivity2ForWorkforce;
@property (nullable, nonatomic, copy) NSString *priorTraining;
@property (nullable, nonatomic, copy) NSString *rootCause1;
@property (nullable, nonatomic, copy) NSString *rootCause2;
@property (nullable, nonatomic, copy) NSDate *safetyReviewDate;
@property (nullable, nonatomic, copy) NSString *sizeOfFire;
@property (nullable, nonatomic, copy) NSString *spillContained;
@property (nullable, nonatomic, copy) NSString *spillSize;
@property (nullable, nonatomic, copy) NSString *spillType;
@property (nullable, nonatomic, copy) NSString *transported;
@property (nullable, nonatomic, copy) NSString *transportedToLocation;
@property (nullable, nonatomic, copy) NSString *vehicleNeedsTowing;
@property (nullable, nonatomic, copy) NSString *weatherConditions;
@property (nullable, nonatomic, copy) NSString *workforceNotificationPosted;
@property (nullable, nonatomic, copy) NSString *wasAccidentAvoidable;
@property (nullable, nonatomic, copy) NSString *whoIsTheFault;

@end

NS_ASSUME_NONNULL_END
