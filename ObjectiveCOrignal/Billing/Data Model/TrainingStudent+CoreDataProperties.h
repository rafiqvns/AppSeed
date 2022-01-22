//
//  TrainingStudent+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 6/6/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingStudent+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrainingStudent (CoreDataProperties)

+ (NSFetchRequest<TrainingStudent *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *category1Name;
@property (nullable, nonatomic, copy) NSString *category1Value;
@property (nullable, nonatomic, copy) NSString *category2Name;
@property (nullable, nonatomic, copy) NSString *category2Value;
@property (nullable, nonatomic, copy) NSString *category3Name;
@property (nullable, nonatomic, copy) NSString *category3Value;
@property (nullable, nonatomic, copy) NSString *category4Name;
@property (nullable, nonatomic, copy) NSString *category4Value;
@property (nullable, nonatomic, copy) NSString *category5Name;
@property (nullable, nonatomic, copy) NSString *category5Value;
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
@property (nullable, nonatomic, copy) NSString *studentId;
@property (nullable, nonatomic, copy) NSString *middleName;

@end

NS_ASSUME_NONNULL_END
