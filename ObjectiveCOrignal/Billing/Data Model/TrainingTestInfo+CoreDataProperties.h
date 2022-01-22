//
//  TrainingTestInfo+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 2/25/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "TrainingTestInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrainingTestInfo (CoreDataProperties)

+ (NSFetchRequest<TrainingTestInfo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *comments;
@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *correctiveLensRequired;
@property (nullable, nonatomic, copy) NSDate *dotExpirationDate;
@property (nullable, nonatomic, copy) NSString *driverHistoryReviewed;
@property (nullable, nonatomic, copy) NSString *driverLicenseClass;
@property (nullable, nonatomic, copy) NSDate *driverLicenseExpirationDate;
@property (nullable, nonatomic, copy) NSString *driverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *driverLicenseState;
@property (nullable, nonatomic, copy) NSString *elapsedTime;
@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSDate *endDateTime;
@property (nullable, nonatomic, copy) NSString *endorsements;
@property (nullable, nonatomic, copy) NSString *equipmentType;
@property (nullable, nonatomic, copy) NSString *evaluationLocation;
@property (nullable, nonatomic, copy) NSString *groupName;
@property (nullable, nonatomic, copy) NSString *groupNumber;
@property (nullable, nonatomic, copy) NSString *instructorEmployeeId;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *parentMobileRecordId;
@property (nullable, nonatomic, copy) NSString *pauseDateTimes;
@property (nullable, nonatomic, copy) NSString *pointsPossible;
@property (nullable, nonatomic, copy) NSString *pointsReceived;
@property (nullable, nonatomic, copy) NSString *powerUnit;
@property (nullable, nonatomic, copy) NSString *restrictions;
@property (nullable, nonatomic, copy) NSDate *startDateTime;
@property (nullable, nonatomic, copy) NSString *studentFirstName;
@property (nullable, nonatomic, copy) NSString *studentLastName;
@property (nullable, nonatomic, copy) NSDate *trainingAccidentDate;
@property (nullable, nonatomic, copy) NSString *trainingAnnual;
@property (nullable, nonatomic, copy) NSString *trainingBehindTheWheel;
@property (nullable, nonatomic, copy) NSString *trainingChangeJob;
@property (nullable, nonatomic, copy) NSString *trainingChangeOfEquipment;
@property (nullable, nonatomic, copy) NSString *trainingEquipment;
@property (nullable, nonatomic, copy) NSString *trainingEye;
@property (nullable, nonatomic, copy) NSString *trainingIncidentFollowUp;
@property (nullable, nonatomic, copy) NSDate *trainingInjuryDate;
@property (nullable, nonatomic, copy) NSDate *trainingLostTimeStartDate;
@property (nullable, nonatomic, copy) NSString *trainingNearMiss;
@property (nullable, nonatomic, copy) NSString *trainingNewHire;
@property (nullable, nonatomic, copy) NSString *trainingPreTrip;
@property (nullable, nonatomic, copy) NSString *trainingProd;
@property (nullable, nonatomic, copy) NSDate *trainingReturnToWorkDate;
@property (nullable, nonatomic, copy) NSString *trainingSWP;
@property (nullable, nonatomic, copy) NSDate *trainingTAWEndDate;
@property (nullable, nonatomic, copy) NSDate *trainingTAWStartDate;
@property (nullable, nonatomic, copy) NSString *trainingVRT;
@property (nullable, nonatomic, copy) NSString *trainingPassengerEvacuation;
@property (nullable, nonatomic, copy) NSString *trainingPassengerPreTrip;

@end

NS_ASSUME_NONNULL_END
