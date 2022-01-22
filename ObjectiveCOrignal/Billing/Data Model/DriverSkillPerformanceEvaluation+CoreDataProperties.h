//
//  DriverSkillPerformanceEvaluation+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverSkillPerformanceEvaluation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DriverSkillPerformanceEvaluation (CoreDataProperties)

+ (NSFetchRequest<DriverSkillPerformanceEvaluation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *applicationTypeUnilateral;
@property (nullable, nonatomic, copy) NSString *applicationTypeJoint;
@property (nullable, nonatomic, copy) NSString *sex;
@property (nullable, nonatomic, copy) NSString *descriptionofimpairmentoramputation;
@property (nullable, nonatomic, copy) NSString *typeofprosthesisworn;
@property (nullable, nonatomic, copy) NSString *statesofoperation;
@property (nullable, nonatomic, copy) NSString *typeofcargo;
@property (nullable, nonatomic, copy) NSString *averageperiodofdrivingtime;
@property (nullable, nonatomic, copy) NSString *typeofoperation;
@property (nullable, nonatomic, copy) NSString *numberofyearsdrivingvehicletype;
@property (nullable, nonatomic, copy) NSString *numberofyearsdrivingallvehicletypes;
@property (nullable, nonatomic, copy) NSString *vehicleType;
@property (nullable, nonatomic, copy) NSString *vehicleSeatingCapacity;
@property (nullable, nonatomic, copy) NSString *vehicleMake;
@property (nullable, nonatomic, copy) NSString *vehicleModel;
@property (nullable, nonatomic, copy) NSString *vehicleYear;
@property (nullable, nonatomic, copy) NSString *vehicleTransmissionType;
@property (nullable, nonatomic, copy) NSString *vehicleNumberofForwardSpeeds;
@property (nullable, nonatomic, copy) NSString *vehicleRearAxleSpeed;
@property (nonatomic) BOOL vehicleTypeBrakeSystem;
@property (nullable, nonatomic, copy) NSString *vehicleTypeSteeringSystem;
@property (nullable, nonatomic, copy) NSString *numberofTrailers;
@property (nullable, nonatomic, copy) NSString *descriptionoftrailers;
@property (nullable, nonatomic, copy) NSString *vehicleModifications;
@property (nullable, nonatomic, copy) NSDate *driverSignatureDate;

@end

NS_ASSUME_NONNULL_END
