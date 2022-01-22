//
//  DriverApplicationHeader+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/5/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverApplicationHeader+CoreDataProperties.h"

@implementation DriverApplicationHeader (CoreDataProperties)

+ (NSFetchRequest<DriverApplicationHeader *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DriverApplicationHeader"];
}

@dynamic company;
@dynamic companyAddress;
@dynamic companyCity;
@dynamic companyState;
@dynamic companyZipcode;
@dynamic dateofBirth;
@dynamic socialSercurityNumber;
@dynamic driverAddress1HowLong;
@dynamic driverAddress2;
@dynamic driverCity2;
@dynamic driverState2;
@dynamic driverZipcode2;
@dynamic driverAddress2HowLong;
@dynamic driverAddress3;
@dynamic driverCity3;
@dynamic driverState3;
@dynamic driverZipcode3;
@dynamic driverAddress3HowLong;
@dynamic driverStraightTruckEquipment;
@dynamic driverStraightTruckDateFrom;
@dynamic driverStraightTruckDateTo;
@dynamic driverStraightTruckTotalMiles;
@dynamic driverTractorTrailerEquipment;
@dynamic driverTractorTrailerDateFrom;
@dynamic driverTractorTrailerDateTo;
@dynamic driverTractorTrailerMilesTotal;
@dynamic driverTractor2TrailersEquipment;
@dynamic driverTractor2TrailersDateFrom;
@dynamic driverTractor2TrailersDateTo;
@dynamic driverTractor2TrailersTotalMiles;
@dynamic driverOtherEquipment;
@dynamic driverOtherDateFrom;
@dynamic driverOtherDateTo;
@dynamic driverOtherTotalMiles;
@dynamic driverLicensePermitDenied;
@dynamic driverLicensePermitRevokedorSuspended;
@dynamic driverLicensePermitNotes;

@end
