//
//  AccidentVehicleReport+CoreDataClass.h
//  MobileOffice
//
//  Created by .D. .D. on 5/21/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "Driver+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum  {
    AccidentRecordTypeUndefined = 0,
    AccidentRecordTypeVehicle = 1,
    AccidentRecordTypeTrailerDollie = 2,
    AccidentRecordTypeWitness = 3,
} AccidentRecordType;


@interface AccidentVehicleReport : Driver
-(NSString*)CSVFormat;
@end

NS_ASSUME_NONNULL_END

#import "AccidentVehicleReport+CoreDataProperties.h"
