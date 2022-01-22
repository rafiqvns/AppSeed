//
//  TrainingBreakLocation+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 4/14/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "TrainingBreakLocation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrainingBreakLocation (CoreDataProperties)

+ (NSFetchRequest<TrainingBreakLocation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *elapsedMinutes;
@property (nullable, nonatomic, copy) NSDate *endDateTime;
@property (nullable, nonatomic, copy) NSString *headerBarcode;
@property (nullable, nonatomic, copy) NSString *headerObjectId;
@property (nullable, nonatomic, copy) NSString *headerObjectType;
@property (nullable, nonatomic, copy) NSString *instructorEmployeeId;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *latitude;
@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, copy) NSString *longitude;
@property (nullable, nonatomic, copy) NSDate *startDateTime;
@property (nullable, nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
