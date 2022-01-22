//
//  AccidentVehicle+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 5/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentVehicle+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AccidentVehicle (CoreDataProperties)

+ (NSFetchRequest<AccidentVehicle *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *assignedLocation;
@property (nullable, nonatomic, copy) NSString *combinationVehicle;
@property (nullable, nonatomic, copy) NSString *companyAddress;
@property (nullable, nonatomic, copy) NSString *companyCity;
@property (nullable, nonatomic, copy) NSString *companyPhone;
@property (nullable, nonatomic, copy) NSString *companyState;
@property (nullable, nonatomic, copy) NSString *companyZipcode;
@property (nullable, nonatomic, copy) NSDate *dateofBirth;
@property (nullable, nonatomic, copy) NSString *descriptionOfDamage;
@property (nullable, nonatomic, copy) NSString *employedBy;
@property (nullable, nonatomic, copy) NSString *insuranceAddress;
@property (nullable, nonatomic, copy) NSString *insuranceAgent;
@property (nullable, nonatomic, copy) NSString *insuranceCity;
@property (nullable, nonatomic, copy) NSString *insuranceCompany;
@property (nullable, nonatomic, copy) NSDate *insuranceExpirationDate;
@property (nullable, nonatomic, copy) NSString *insurancePhone;
@property (nullable, nonatomic, copy) NSString *insurancePolicyNumber;
@property (nullable, nonatomic, copy) NSString *insuranceState;
@property (nullable, nonatomic, copy) NSString *insuranceZipcode;
@property (nullable, nonatomic, copy) NSString *insuredByDriver;
@property (nullable, nonatomic, copy) NSString *registeredByDriver;
@property (nullable, nonatomic, copy) NSString *registrationAddress;
@property (nullable, nonatomic, copy) NSString *registrationCity;
@property (nullable, nonatomic, copy) NSDate *registrationExpirationDate;
@property (nullable, nonatomic, copy) NSString *registrationName;
@property (nullable, nonatomic, copy) NSString *registrationNumber;
@property (nullable, nonatomic, copy) NSString *registrationState;
@property (nullable, nonatomic, copy) NSString *registrationZipcode;
@property (nullable, nonatomic, copy) NSString *vehicleMake;
@property (nullable, nonatomic, copy) NSString *vehicleModel;
@property (nullable, nonatomic, copy) NSString *vehicleType;
@property (nullable, nonatomic, copy) NSString *vehicleYear;
@property (nullable, nonatomic, copy) NSString *vin;

@end

NS_ASSUME_NONNULL_END
