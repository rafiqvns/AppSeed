//
//  TrainingEquipmentAggregate.h
//  CSD
//
//  Created by .D. .D. on 11/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"
#import "TrainingEquipment+CoreDataClass.h"

#define EQU @"EQU"

NS_ASSUME_NONNULL_BEGIN

@interface TrainingEquipmentAggregate : Aggregate
-(NSArray*)getTrainingEquipmentForDrivingLicenseNumber:(NSString*)number driverLicenseState:(NSString*)state andInstructor:(NSString*)instructorEmployeeId;
-(NSArray*)getEquipmentUsedForTestInfo:(NSString*)testInfoMobileRecordId;
@end

NS_ASSUME_NONNULL_END
