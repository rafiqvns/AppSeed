//
//  DriverApplicationDetail+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 3/5/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverApplicationDetail+CoreDataProperties.h"

@implementation DriverApplicationDetail (CoreDataProperties)

+ (NSFetchRequest<DriverApplicationDetail *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DriverApplicationDetail"];
}

@dynamic location;
@dynamic charge;
@dynamic penalty;

@end
