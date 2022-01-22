//
//  DriverTurn+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 11/8/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "DriverTurn+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DriverTurn (CoreDataProperties)

+ (NSFetchRequest<DriverTurn *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *instructorId;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *latitude;
@property (nullable, nonatomic, copy) NSString *longitude;
@property (nullable, nonatomic, copy) NSString *studentFirstName;
@property (nullable, nonatomic, copy) NSString *studentLastName;
@property (nullable, nonatomic, copy) NSString *turnType;
@property (nullable, nonatomic, copy) NSString *masterMobileRecordId;

@end

NS_ASSUME_NONNULL_END
