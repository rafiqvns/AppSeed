//
//  TrainingInstructor+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingInstructor+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrainingInstructor (CoreDataProperties)

+ (NSFetchRequest<TrainingInstructor *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *correctiveLensRequired;
@property (nullable, nonatomic, copy) NSDate *dotExpirationDate1;
@property (nullable, nonatomic, copy) NSDate *driverLicenseExpirationDate;
@property (nullable, nonatomic, copy) NSString *driverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *driverLicenseState;
@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSString *endorsements;
@property (nullable, nonatomic, copy) NSString *firstName;
@property (nullable, nonatomic, copy) NSString *lastName;
@property (nullable, nonatomic, copy) NSString *studentClass;
@property (nullable, nonatomic, copy) NSString *instructorId;

@end

NS_ASSUME_NONNULL_END
