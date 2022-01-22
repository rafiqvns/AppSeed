//
//  TrainingCompany+CoreDataProperties.m
//  CSD
//
//  Created by .D. .D. on 12/27/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingCompany+CoreDataProperties.h"

@implementation TrainingCompany (CoreDataProperties)

+ (NSFetchRequest<TrainingCompany *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TrainingCompany"];
}

@dynamic address;
@dynamic companyId;
@dynamic category1Name;
@dynamic category1Value;
@dynamic category2Name;
@dynamic category2Value;
@dynamic category3Name;
@dynamic category3Value;
@dynamic category4Name;
@dynamic category4Value;
@dynamic category5Name;
@dynamic category5Value;
@dynamic city;
@dynamic phone;
@dynamic state;
@dynamic zip;
@dynamic drivingSchool;

@end
