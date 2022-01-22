//
//  DriverTurn+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 11/8/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "DriverTurn+CoreDataProperties.h"

@implementation DriverTurn (CoreDataProperties)

+ (NSFetchRequest<DriverTurn *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DriverTurn"];
}

@dynamic company;
@dynamic employeeId;
@dynamic instructorFirstName;
@dynamic instructorId;
@dynamic instructorLastName;
@dynamic latitude;
@dynamic longitude;
@dynamic studentFirstName;
@dynamic studentLastName;
@dynamic turnType;
@dynamic masterMobileRecordId;

@end
