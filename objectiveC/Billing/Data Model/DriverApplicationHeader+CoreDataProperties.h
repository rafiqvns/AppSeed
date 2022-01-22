//
//  DriverApplicationHeader+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/5/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverApplicationHeader+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DriverApplicationHeader (CoreDataProperties)

+ (NSFetchRequest<DriverApplicationHeader *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *companyAddress;
@property (nullable, nonatomic, copy) NSString *companyCity;
@property (nullable, nonatomic, copy) NSString *companyState;
@property (nullable, nonatomic, copy) NSString *companyZipcode;
@property (nullable, nonatomic, copy) NSDate *dateofBirth;
@property (nullable, nonatomic, copy) NSString *socialSercurityNumber;
@property (nullable, nonatomic, copy) NSString *driverAddress1HowLong;
@property (nullable, nonatomic, copy) NSString *driverAddress2;
@property (nullable, nonatomic, copy) NSString *driverCity2;
@property (nullable, nonatomic, copy) NSString *driverState2;
@property (nullable, nonatomic, copy) NSString *driverZipcode2;
@property (nullable, nonatomic, copy) NSString *driverAddress2HowLong;
@property (nullable, nonatomic, copy) NSString *driverAddress3;
@property (nullable, nonatomic, copy) NSString *driverCity3;
@property (nullable, nonatomic, copy) NSString *driverState3;
@property (nullable, nonatomic, copy) NSString *driverZipcode3;
@property (nullable, nonatomic, copy) NSString *driverAddress3HowLong;
@property (nullable, nonatomic, copy) NSString *driverStraightTruckEquipment;
@property (nullable, nonatomic, copy) NSDate *driverStraightTruckDateFrom;
@property (nullable, nonatomic, copy) NSDate *driverStraightTruckDateTo;
@property (nullable, nonatomic, copy) NSString *driverStraightTruckTotalMiles;
@property (nullable, nonatomic, copy) NSString *driverTractorTrailerEquipment;
@property (nullable, nonatomic, copy) NSDate *driverTractorTrailerDateFrom;
@property (nullable, nonatomic, copy) NSDate *driverTractorTrailerDateTo;
@property (nullable, nonatomic, copy) NSString *driverTractorTrailerMilesTotal;
@property (nullable, nonatomic, copy) NSString *driverTractor2TrailersEquipment;
@property (nullable, nonatomic, copy) NSDate *driverTractor2TrailersDateFrom;
@property (nullable, nonatomic, copy) NSDate *driverTractor2TrailersDateTo;
@property (nullable, nonatomic, copy) NSString *driverTractor2TrailersTotalMiles;
@property (nullable, nonatomic, copy) NSString *driverOtherEquipment;
@property (nullable, nonatomic, copy) NSDate *driverOtherDateFrom;
@property (nullable, nonatomic, copy) NSDate *driverOtherDateTo;
@property (nullable, nonatomic, copy) NSString *driverOtherTotalMiles;
@property (nullable, nonatomic, copy) NSString *driverLicensePermitDenied;
@property (nullable, nonatomic, copy) NSString *driverLicensePermitRevokedorSuspended;
@property (nullable, nonatomic, copy) NSString *driverLicensePermitNotes;

@end

NS_ASSUME_NONNULL_END
