//
//  AccidentTrailerDollie+CoreDataProperties.m
//  MobileOffice
//
//  Created by .D. .D. on 5/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentTrailerDollie+CoreDataProperties.h"

@implementation AccidentTrailerDollie (CoreDataProperties)

+ (NSFetchRequest<AccidentTrailerDollie *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AccidentTrailerDollie"];
}

@dynamic inspectionCurrent;
@dynamic licensePlateNumber;
@dynamic licenseState;
@dynamic registrationCurrent;
@dynamic trailerSize;
@dynamic trailerMake;
@dynamic dollyType;

@end
