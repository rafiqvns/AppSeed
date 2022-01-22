//
//  TestDataHeader+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/3/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "TestDataHeader+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TestDataHeader (CoreDataProperties)

+ (NSFetchRequest<TestDataHeader *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *correctiveLensRequired;
@property (nullable, nonatomic, copy) NSString *department;
@property (nullable, nonatomic, copy) NSString *disqualifiedRemarks;
@property (nullable, nonatomic, copy) NSDate *dotExpirationDate;
@property (nullable, nonatomic, copy) NSString *dotNumber;
@property (nullable, nonatomic, copy) NSString *driverHistoryReviewed;
@property (nullable, nonatomic, copy) NSString *driverLicenseClass;
@property (nullable, nonatomic, copy) NSDate *driverLicenseExpirationDate;
@property (nullable, nonatomic, copy) NSString *driverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *driverLicenseState;
@property (nullable, nonatomic, copy) NSString *driverName;
@property (nullable, nonatomic, copy) NSString *elapsedTime;
@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSString *employeeRecordId;
@property (nullable, nonatomic, copy) NSDate *endDateTime;
@property (nullable, nonatomic, copy) NSString *endorsements;
@property (nullable, nonatomic, copy) NSString *equipmentClean;
@property (nullable, nonatomic, copy) NSString *equipmentReady;
@property (nullable, nonatomic, copy) NSString *evaluatorName;
@property (nullable, nonatomic, copy) NSString *evaluatorTitle;
@property (nullable, nonatomic, copy) NSString *finishOdometer;
@property (nullable, nonatomic, copy) NSString *instructorEmployeeId;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *keysReady;
@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, copy) NSDate *medicalCardExpirationDate;
@property (nullable, nonatomic, copy) NSString *miles;
@property (nullable, nonatomic, copy) NSString *numberofTrailers;
@property (nullable, nonatomic, copy) NSString *onTime;
@property (nullable, nonatomic, copy) NSString *pauseDateTimes;
@property (nullable, nonatomic, copy) NSString *pointsPossible;
@property (nullable, nonatomic, copy) NSString *pointsReceived;
@property (nullable, nonatomic, copy) NSString *powerUnit;
@property (nullable, nonatomic, copy) NSString *qualifiedYesNo;
@property (nullable, nonatomic, copy) NSString *restrictions;
@property (nullable, nonatomic, copy) NSString *routeNumber;
@property (nullable, nonatomic, copy) NSDate *startDateTime;
@property (nullable, nonatomic, copy) NSString *startOdometer;
@property (nullable, nonatomic, copy) NSString *studentFirstName;
@property (nullable, nonatomic, copy) NSString *studentLastName;
@property (nullable, nonatomic, copy) NSDate *testDate;
@property (nullable, nonatomic, copy) NSString *testMiles;
@property (nullable, nonatomic, copy) NSString *testRemarks;
@property (nullable, nonatomic, copy) NSString *testResult;
@property (nullable, nonatomic, copy) NSString *testState;
@property (nullable, nonatomic, copy) NSString *timecardSystemReady;
@property (nullable, nonatomic, copy) NSString *trailerLength;
@property (nullable, nonatomic, copy) NSString *observerFirstName;
@property (nullable, nonatomic, copy) NSString *observerLastName;

@end

NS_ASSUME_NONNULL_END
