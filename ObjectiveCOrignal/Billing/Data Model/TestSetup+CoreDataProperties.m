//
//  TestSetup+CoreDataProperties.m
//  Quality
//
//  Created by .D. .D. on 1/29/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TestSetup+CoreDataProperties.h"

@implementation TestSetup (CoreDataProperties)

+ (NSFetchRequest<TestSetup *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TestSetup"];
}

@dynamic numberOfSections;
@dynamic possiblePoints;
@dynamic possibleSections;
@dynamic sectionTitles;

@end
