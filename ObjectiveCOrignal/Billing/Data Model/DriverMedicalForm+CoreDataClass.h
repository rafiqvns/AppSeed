//
//  DriverMedicalForm+CoreDataClass.h
//  CSD
//
//  Created by .D. .D. on 3/10/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "Driver+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface DriverMedicalForm : Driver
-(NSString*)CSVFormat;

@end

NS_ASSUME_NONNULL_END

#import "DriverMedicalForm+CoreDataProperties.h"
