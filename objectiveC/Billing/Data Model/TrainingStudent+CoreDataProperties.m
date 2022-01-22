//
//  TrainingStudent+CoreDataProperties.m
//  MobileOffice
//
//  Created by .D. .D. on 6/6/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingStudent+CoreDataProperties.h"

@implementation TrainingStudent (CoreDataProperties)

+ (NSFetchRequest<TrainingStudent *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"TrainingStudent"];
}

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
@dynamic company;
@dynamic correctiveLensRequired;
@dynamic dotExpirationDate1;
@dynamic driverLicenseExpirationDate;
@dynamic driverLicenseNumber;
@dynamic driverLicenseState;
@dynamic employeeId;
@dynamic endorsements;
@dynamic firstName;
@dynamic lastName;
@dynamic studentClass;
@dynamic studentId;
@dynamic middleName;

@end
