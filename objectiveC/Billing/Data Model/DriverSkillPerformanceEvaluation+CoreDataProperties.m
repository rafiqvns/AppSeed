//
//  DriverSkillPerformanceEvaluation+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverSkillPerformanceEvaluation+CoreDataProperties.h"

@implementation DriverSkillPerformanceEvaluation (CoreDataProperties)

+ (NSFetchRequest<DriverSkillPerformanceEvaluation *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DriverSkillPerformanceEvaluation"];
}

@dynamic applicationTypeUnilateral;
@dynamic applicationTypeJoint;
@dynamic sex;
@dynamic descriptionofimpairmentoramputation;
@dynamic typeofprosthesisworn;
@dynamic statesofoperation;
@dynamic typeofcargo;
@dynamic averageperiodofdrivingtime;
@dynamic typeofoperation;
@dynamic numberofyearsdrivingvehicletype;
@dynamic numberofyearsdrivingallvehicletypes;
@dynamic vehicleType;
@dynamic vehicleSeatingCapacity;
@dynamic vehicleMake;
@dynamic vehicleModel;
@dynamic vehicleYear;
@dynamic vehicleTransmissionType;
@dynamic vehicleNumberofForwardSpeeds;
@dynamic vehicleRearAxleSpeed;
@dynamic vehicleTypeBrakeSystem;
@dynamic vehicleTypeSteeringSystem;
@dynamic numberofTrailers;
@dynamic descriptionoftrailers;
@dynamic vehicleModifications;
@dynamic driverSignatureDate;

@end
