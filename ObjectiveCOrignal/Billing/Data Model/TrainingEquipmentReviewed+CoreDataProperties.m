//
//  TrainingEquipmentReviewed+CoreDataProperties.m
//  Water
//
//  Created by .D. .D. on 11/20/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingEquipmentReviewed+CoreDataProperties.h"

@implementation TrainingEquipmentReviewed (CoreDataProperties)

+ (NSFetchRequest<TrainingEquipmentReviewed *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TrainingEquipmentReviewed"];
}

@dynamic company;
@dynamic employeeId;
@dynamic equipmentType;
@dynamic instructorEmployeeId;
@dynamic instructorFirstName;
@dynamic instructorLastName;
@dynamic lVCLength;
@dynamic lVCLengthNotes;
@dynamic lVCType;
@dynamic lVCTypeNotes;
@dynamic parentMobileRecordId;
@dynamic singleTrailerLength;
@dynamic singleTrailerNotes;
@dynamic studentDriverLicenseNumber;
@dynamic studentDriverLicenseState;
@dynamic studentFirstName;
@dynamic studentLastName;
@dynamic transmissionType;
@dynamic transmissionTypeNotes;
@dynamic vehicleManufacturer;
@dynamic vehicleManufacturerNotes;
@dynamic vehicleType;
@dynamic vehicleTypeNotes;
@dynamic dollyGearType;
@dynamic dollyGearTypeNotes;

@end
