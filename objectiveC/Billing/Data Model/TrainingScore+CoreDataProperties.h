//
//  TrainingScore+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 12/27/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingScore+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrainingScore (CoreDataProperties)

+ (NSFetchRequest<TrainingScore *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *studentFirstName;
@property (nullable, nonatomic, copy) NSString *studentLastName;
@property (nullable, nonatomic, copy) NSString *driverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *driverLicenseState;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *instructorEmployeeId;
@property (nullable, nonatomic, copy) NSString *testName;
@property (nullable, nonatomic, copy) NSString *sectionName;
@property (nullable, nonatomic, copy) NSString *elapsedTime;
@property (nullable, nonatomic, copy) NSString *pointsReceived;
@property (nullable, nonatomic, copy) NSString *pointsPossible;
@property (nullable, nonatomic, copy) NSString *masterMobileRecordId;

@end

NS_ASSUME_NONNULL_END
