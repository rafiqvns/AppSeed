//
//  AccidentVehicle+CoreDataProperties.m
//  MobileOffice
//
//  Created by .D. .D. on 5/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentVehicle+CoreDataProperties.h"

@implementation AccidentVehicle (CoreDataProperties)

+ (NSFetchRequest<AccidentVehicle *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AccidentVehicle"];
}

@dynamic assignedLocation;
@dynamic combinationVehicle;
@dynamic companyAddress;
@dynamic companyCity;
@dynamic companyPhone;
@dynamic companyState;
@dynamic companyZipcode;
@dynamic dateofBirth;
@dynamic descriptionOfDamage;
@dynamic employedBy;
@dynamic insuranceAddress;
@dynamic insuranceAgent;
@dynamic insuranceCity;
@dynamic insuranceCompany;
@dynamic insuranceExpirationDate;
@dynamic insurancePhone;
@dynamic insurancePolicyNumber;
@dynamic insuranceState;
@dynamic insuranceZipcode;
@dynamic insuredByDriver;
@dynamic registeredByDriver;
@dynamic registrationAddress;
@dynamic registrationCity;
@dynamic registrationExpirationDate;
@dynamic registrationName;
@dynamic registrationNumber;
@dynamic registrationState;
@dynamic registrationZipcode;
@dynamic vehicleMake;
@dynamic vehicleModel;
@dynamic vehicleType;
@dynamic vehicleYear;
@dynamic vin;

@end
