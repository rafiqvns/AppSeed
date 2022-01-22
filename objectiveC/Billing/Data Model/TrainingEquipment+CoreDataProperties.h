//
//  TrainingEquipment+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 11/21/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingEquipment+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrainingEquipment (CoreDataProperties)

+ (NSFetchRequest<TrainingEquipment *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *dolly1Number;
@property (nullable, nonatomic, copy) NSString *dolly2Number;
@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSString *instructorEmployeeId;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *parentMobileRecordId;
@property (nullable, nonatomic, copy) NSString *studentDriverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *studentDriverLicenseState;
@property (nullable, nonatomic, copy) NSString *studentFirstName;
@property (nullable, nonatomic, copy) NSString *studentLastName;
@property (nullable, nonatomic, copy) NSString *trailer1Number;
@property (nullable, nonatomic, copy) NSString *trailer2Number;
@property (nullable, nonatomic, copy) NSString *trailer3Number;
@property (nullable, nonatomic, copy) NSString *vehicleNumber;
@property (nullable, nonatomic, copy) NSString *transmissionType;
@property (nullable, nonatomic, copy) NSString *transmissionTypeOther;
@property (nullable, nonatomic, copy) NSString *vehicleManufacturer;
@property (nullable, nonatomic, copy) NSString *vehicleManufacturerOther;
@property (nullable, nonatomic, copy) NSString *vehicleType;
@property (nullable, nonatomic, copy) NSString *vehicleTypeOther;
@property (nullable, nonatomic, copy) NSString *singleTrailerLength;
@property (nullable, nonatomic, copy) NSString *singleTrailerLengthOther;
@property (nullable, nonatomic, copy) NSString *lVCLength;
@property (nullable, nonatomic, copy) NSString *lVCLengthOther;
@property (nullable, nonatomic, copy) NSString *lVCType;
@property (nullable, nonatomic, copy) NSString *lVCTypeOther;
@property (nullable, nonatomic, copy) NSString *powerUnit;
@property (nullable, nonatomic, copy) NSString *dollyGearType;
@property (nullable, nonatomic, copy) NSString *dollyGearTypeOther;

@end

NS_ASSUME_NONNULL_END
