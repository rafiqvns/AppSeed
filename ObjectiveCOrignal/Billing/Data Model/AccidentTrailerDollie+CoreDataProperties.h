//
//  AccidentTrailerDollie+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 5/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentTrailerDollie+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AccidentTrailerDollie (CoreDataProperties)

+ (NSFetchRequest<AccidentTrailerDollie *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *inspectionCurrent;
@property (nullable, nonatomic, copy) NSString *licensePlateNumber;
@property (nullable, nonatomic, copy) NSString *licenseState;
@property (nullable, nonatomic, copy) NSString *registrationCurrent;
@property (nullable, nonatomic, copy) NSString *trailerSize;
@property (nullable, nonatomic, copy) NSString *trailerMake;
@property (nullable, nonatomic, copy) NSString *dollyType;

@end

NS_ASSUME_NONNULL_END
