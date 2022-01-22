//
//  TrainingEquipmentReviewed+CoreDataProperties.h
//  Water
//
//  Created by .D. .D. on 11/20/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingEquipmentReviewed+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrainingEquipmentReviewed (CoreDataProperties)

+ (NSFetchRequest<TrainingEquipmentReviewed *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSString *equipmentType;
@property (nullable, nonatomic, copy) NSString *instructorEmployeeId;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *lVCLength;
@property (nullable, nonatomic, copy) NSString *lVCLengthNotes;
@property (nullable, nonatomic, copy) NSString *lVCType;
@property (nullable, nonatomic, copy) NSString *lVCTypeNotes;
@property (nullable, nonatomic, copy) NSString *parentMobileRecordId;
@property (nullable, nonatomic, copy) NSString *singleTrailerLength;
@property (nullable, nonatomic, copy) NSString *singleTrailerNotes;
@property (nullable, nonatomic, copy) NSString *studentDriverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *studentDriverLicenseState;
@property (nullable, nonatomic, copy) NSString *studentFirstName;
@property (nullable, nonatomic, copy) NSString *studentLastName;
@property (nullable, nonatomic, copy) NSString *transmissionType;
@property (nullable, nonatomic, copy) NSString *transmissionTypeNotes;
@property (nullable, nonatomic, copy) NSString *vehicleManufacturer;
@property (nullable, nonatomic, copy) NSString *vehicleManufacturerNotes;
@property (nullable, nonatomic, copy) NSString *vehicleType;
@property (nullable, nonatomic, copy) NSString *vehicleTypeNotes;
@property (nullable, nonatomic, copy) NSString *dollyGearType;
@property (nullable, nonatomic, copy) NSString *dollyGearTypeNotes;

@end

NS_ASSUME_NONNULL_END
