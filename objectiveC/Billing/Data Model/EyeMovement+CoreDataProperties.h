//
//  EyeMovement+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 12/12/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "EyeMovement+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EyeMovement (CoreDataProperties)

+ (NSFetchRequest<EyeMovement *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *driverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *driverLicenseState;
@property (nullable, nonatomic, copy) NSString *eyeMovement;
@property (nullable, nonatomic, copy) NSDate *finishDateTime;
@property (nullable, nonatomic, copy) NSString *frontCounter;
@property (nullable, nonatomic, copy) NSString *instructorEmployeeId;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *leftMirrorCounter;
@property (nullable, nonatomic, copy) NSString *masterMobileRecordId;
@property (nullable, nonatomic, copy) NSString *rearCounter;
@property (nullable, nonatomic, copy) NSString *rightMirrorCounter;
@property (nullable, nonatomic, copy) NSString *startTimes;
@property (nullable, nonatomic, copy) NSString *stopTimes;
@property (nullable, nonatomic, copy) NSString *studentEmployeeId;
@property (nullable, nonatomic, copy) NSString *studentFirstName;
@property (nullable, nonatomic, copy) NSString *studentLastName;
@property (nullable, nonatomic, copy) NSString *eyeLeadCounter;
@property (nullable, nonatomic, copy) NSString *followTimeCounter;
@property (nullable, nonatomic, copy) NSString *gaugesCounter;
@property (nullable, nonatomic, copy) NSString *intersectionsCounter;
@property (nullable, nonatomic, copy) NSString *parkedCarsCounter;
@property (nullable, nonatomic, copy) NSString *pedestriansCounter;

@end

NS_ASSUME_NONNULL_END
