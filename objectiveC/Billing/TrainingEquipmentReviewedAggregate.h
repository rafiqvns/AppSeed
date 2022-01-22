//
//  TrainingEquipmentReviewedAggregate.h
//  CSD
//
//  Created by .D. .D. on 11/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"

NS_ASSUME_NONNULL_BEGIN

#define SET_EQUIPMENT_REVIEWED @"setEquipmentReviewed"

@interface TrainingEquipmentReviewedAggregate : Aggregate
-(NSArray*)getTrainingEquipmentForDrivingLicenseNumber:(NSString*)number driverLicenseState:(NSString*)state andInstructor:(NSString*)instructorEmployeeId;
-(NSArray*)getEquipmentReviewedForTestInfo:(NSString*)testInfoMobileRecordId;
@end

NS_ASSUME_NONNULL_END
