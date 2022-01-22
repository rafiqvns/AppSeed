//
//  TrainingEquipment+CoreDataClass.h
//  CSD
//
//  Created by .D. .D. on 11/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "RCOObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrainingEquipment : RCOObject
-(NSString*)CSVFormat;
-(NSString*)trailerNumber;
-(NSString*)TransmissionType;
-(NSString*)Trailer;
@end

NS_ASSUME_NONNULL_END

#import "TrainingEquipment+CoreDataProperties.h"
