//
//  TrainingEquipment+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 11/21/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingEquipment+CoreDataProperties.h"

@implementation TrainingEquipment (CoreDataProperties)

+ (NSFetchRequest<TrainingEquipment *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TrainingEquipment"];
}

@dynamic company;
@dynamic dolly1Number;
@dynamic dolly2Number;
@dynamic employeeId;
@dynamic instructorEmployeeId;
@dynamic instructorFirstName;
@dynamic instructorLastName;
@dynamic parentMobileRecordId;
@dynamic studentDriverLicenseNumber;
@dynamic studentDriverLicenseState;
@dynamic studentFirstName;
@dynamic studentLastName;
@dynamic trailer1Number;
@dynamic trailer2Number;
@dynamic trailer3Number;
@dynamic vehicleNumber;
@dynamic transmissionType;
@dynamic transmissionTypeOther;
@dynamic vehicleManufacturer;
@dynamic vehicleManufacturerOther;
@dynamic vehicleType;
@dynamic vehicleTypeOther;
@dynamic singleTrailerLength;
@dynamic singleTrailerLengthOther;
@dynamic lVCLength;
@dynamic lVCLengthOther;
@dynamic lVCType;
@dynamic lVCTypeOther;
@dynamic powerUnit;
@dynamic dollyGearType;
@dynamic dollyGearTypeOther;

@end
