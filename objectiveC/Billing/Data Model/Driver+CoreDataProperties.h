//
//  Driver+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 6/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "Driver+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Driver (CoreDataProperties)

+ (NSFetchRequest<Driver *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *driverLicenseClass;
@property (nullable, nonatomic, copy) NSDate *driverLicenseExpirationDate;
@property (nullable, nonatomic, copy) NSString *driverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *driverLicenseState;
@property (nullable, nonatomic, copy) NSString *homePhone;
@property (nullable, nonatomic, copy) NSString *mobilePhone;
@property (nullable, nonatomic, copy) NSString *workPhone;
@property (nullable, nonatomic, copy) NSString *middleName;

@end

NS_ASSUME_NONNULL_END
