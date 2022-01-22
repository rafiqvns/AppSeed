//
//  TestDataDetail+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 12/12/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TestDataDetail+CoreDataProperties.h"

@implementation TestDataDetail (CoreDataProperties)

+ (NSFetchRequest<TestDataDetail *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TestDataDetail"];
}

@dynamic company;
@dynamic employeeId;
@dynamic employeeRecordId;
@dynamic instructorEmployeeId;
@dynamic instructorFirstName;
@dynamic instructorLastName;
@dynamic location;
@dynamic odometer;
@dynamic score;
@dynamic studentFirstName;
@dynamic studentLastName;
@dynamic testItemName;
@dynamic testItemNumber;
@dynamic testName;
@dynamic testNumber;
@dynamic testSectionName;
@dynamic testSectionNumber;
@dynamic testTeachingString;
@dynamic trailerNumber;
@dynamic leg;
@dynamic equipmentUsedMobileRecordId;

@end
