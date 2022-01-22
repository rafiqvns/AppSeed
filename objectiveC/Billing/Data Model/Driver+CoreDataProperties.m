//
//  Driver+CoreDataProperties.m
//  MobileOffice
//
//  Created by .D. .D. on 6/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "Driver+CoreDataProperties.h"

@implementation Driver (CoreDataProperties)

+ (NSFetchRequest<Driver *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Driver"];
}

@dynamic driverLicenseClass;
@dynamic driverLicenseExpirationDate;
@dynamic driverLicenseNumber;
@dynamic driverLicenseState;
@dynamic homePhone;
@dynamic mobilePhone;
@dynamic workPhone;
@dynamic middleName;

@end
