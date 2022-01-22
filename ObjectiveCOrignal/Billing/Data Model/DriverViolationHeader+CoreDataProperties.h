//
//  DriverViolationHeader+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverViolationHeader+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DriverViolationHeader (CoreDataProperties)

+ (NSFetchRequest<DriverViolationHeader *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *socialSercurityNumber;
@property (nullable, nonatomic, copy) NSDate *employmentDate;
@property (nullable, nonatomic, copy) NSString *terminalCity;
@property (nullable, nonatomic, copy) NSString *terminalState;
@property (nullable, nonatomic, copy) NSString *violationsthisyear;
@property (nullable, nonatomic, copy) NSString *carrierName;
@property (nullable, nonatomic, copy) NSString *carrierAddress;
@property (nullable, nonatomic, copy) NSString *reviewedBy;
@property (nullable, nonatomic, copy) NSDate *reviewedDate;
@property (nullable, nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
