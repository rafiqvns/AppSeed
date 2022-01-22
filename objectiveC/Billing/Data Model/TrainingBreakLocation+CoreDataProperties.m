//
//  TrainingBreakLocation+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 4/14/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "TrainingBreakLocation+CoreDataProperties.h"

@implementation TrainingBreakLocation (CoreDataProperties)

+ (NSFetchRequest<TrainingBreakLocation *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TrainingBreakLocation"];
}

@dynamic elapsedMinutes;
@dynamic endDateTime;
@dynamic headerBarcode;
@dynamic headerObjectId;
@dynamic headerObjectType;
@dynamic instructorEmployeeId;
@dynamic instructorFirstName;
@dynamic instructorLastName;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic startDateTime;
@dynamic title;

@end
