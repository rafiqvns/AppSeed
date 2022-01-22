//
//  User+CoreDataProperties.m
//  MobileOffice
//
//  Created by .D. .D. on 10/18/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"User"];
}

@dynamic address1;
@dynamic address2;
@dynamic budget;
//@dynamic companyId;
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
@dynamic category6Name;
@dynamic category6Value;
@dynamic cell;
@dynamic chartRef;
@dynamic city;
@dynamic clientName;
@dynamic clientNumber;
@dynamic company;
@dynamic contactName;
@dynamic correctiveLensRequired;
@dynamic country;
@dynamic currentUserIdent;
@dynamic customerNumber;
@dynamic dateOfBirth;
@dynamic dateOfHire;
@dynamic detractors;
@dynamic discountItem;
@dynamic discountService;
@dynamic dOTExpirationDate;
@dynamic driverDutyStatus;
@dynamic driverELDExempt;
@dynamic driverLicenseClass;
@dynamic driverLicenseExpirationDate;
@dynamic driverLicenseNumber;
@dynamic driverLicenseState;
@dynamic email;
@dynamic employeeNumber;
@dynamic endorsements;
@dynamic firstname;
@dynamic growth;
@dynamic homePhoneNumber;
@dynamic isActive;
@dynamic jobType;
@dynamic latitude;
@dynamic leadSource;
@dynamic location;
@dynamic longitude;
@dynamic mailcode;
@dynamic managerEmployeeId;
@dynamic managerName;
@dynamic managerRecordId;
@dynamic metricSystem;
@dynamic middleName;
@dynamic mobilePhoneNumber;
@dynamic nationalIdentifier;
@dynamic nextStep;
@dynamic notifyGroupName;
@dynamic password;
@dynamic phone;
@dynamic referal;
@dynamic salesTaxRateRecordId;
@dynamic salutation;
@dynamic sendGPSLocation;
@dynamic sex;
@dynamic state;
@dynamic surname;
@dynamic territory;
@dynamic timerAutoSync;
@dynamic title;
@dynamic url;
@dynamic userGroupName;
@dynamic userIdent;
@dynamic userNotes1;
@dynamic userNotes2;
@dynamic userNumber;
@dynamic userType;
@dynamic value;
@dynamic workPhoneNumber;
@dynamic zip;
@dynamic quota;

@end
