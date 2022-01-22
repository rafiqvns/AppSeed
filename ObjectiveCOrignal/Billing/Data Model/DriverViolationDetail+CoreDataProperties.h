//
//  DriverViolationDetail+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverViolationDetail+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DriverViolationDetail (CoreDataProperties)

+ (NSFetchRequest<DriverViolationDetail *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *violationOffense;
@property (nullable, nonatomic, copy) NSString *violationLocation;
@property (nullable, nonatomic, copy) NSString *violationtypeofvehicle;

@end

NS_ASSUME_NONNULL_END
