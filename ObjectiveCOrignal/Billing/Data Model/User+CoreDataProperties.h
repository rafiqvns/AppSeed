//
//  User+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 10/18/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "User.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *rcoObjectClass;
@property (nullable, nonatomic, copy) NSString *rcoObjectType;
@property (nullable, nonatomic, copy) NSString *rcoObjectId;

@property (nullable, nonatomic, copy) NSString *userId;
@property (nullable, nonatomic, copy) NSString *address1;
@property (nullable, nonatomic, copy) NSString *address2;
@property (nullable, nonatomic, copy) NSString *budget;
@property (nullable, nonatomic, copy) NSString *category1Name;
@property (nullable, nonatomic, copy) NSString *category1Value;
@property (nullable, nonatomic, copy) NSString *category2Name;
@property (nullable, nonatomic, copy) NSString *category2Value;
@property (nullable, nonatomic, copy) NSString *category3Name;
@property (nullable, nonatomic, copy) NSString *category3Value;
@property (nullable, nonatomic, copy) NSString *category4Name;
@property (nullable, nonatomic, copy) NSString *category4Value;
@property (nullable, nonatomic, copy) NSString *category5Name;
@property (nullable, nonatomic, copy) NSString *category5Value;
@property (nullable, nonatomic, copy) NSString *category6Name;
@property (nullable, nonatomic, copy) NSString *category6Value;
@property (nullable, nonatomic, copy) NSString *cell;
@property (nullable, nonatomic, copy) NSString *chartRef;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *clientName;
@property (nullable, nonatomic, copy) NSString *clientNumber;
@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *contactName;
@property (nullable, nonatomic, copy) NSString *correctiveLensRequired;
@property (nullable, nonatomic, copy) NSString *country;
@property (nullable, nonatomic, copy) NSString *currentUserIdent;
@property (nullable, nonatomic, copy) NSString *customerNumber;
@property (nullable, nonatomic, copy) NSDate *dateOfBirth;
@property (nullable, nonatomic, copy) NSDate *dateOfHire;
@property (nullable, nonatomic, copy) NSString *detractors;
@property (nullable, nonatomic, copy) NSString *discountItem;
@property (nullable, nonatomic, copy) NSString *discountService;
@property (nullable, nonatomic, copy) NSDate *dOTExpirationDate;
@property (nullable, nonatomic, copy) NSString *driverDutyStatus;
@property (nullable, nonatomic, copy) NSString *driverELDExempt;
@property (nullable, nonatomic, copy) NSString *driverLicenseClass;
@property (nullable, nonatomic, copy) NSDate *driverLicenseExpirationDate;
@property (nullable, nonatomic, copy) NSString *driverLicenseNumber;
@property (nullable, nonatomic, copy) NSString *driverLicenseState;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *employeeNumber;
@property (nullable, nonatomic, copy) NSString *endorsements;
@property (nullable, nonatomic, copy) NSString *firstname;
@property (nullable, nonatomic, copy) NSString *growth;
@property (nullable, nonatomic, copy) NSString *homePhoneNumber;
@property (nullable, nonatomic, copy) NSNumber *isActive;
@property (nullable, nonatomic, copy) NSString *jobType;
@property (nullable, nonatomic, copy) NSNumber *latitude;
@property (nullable, nonatomic, copy) NSString *leadSource;
@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, copy) NSNumber *longitude;
@property (nullable, nonatomic, copy) NSString *mailcode;
@property (nullable, nonatomic, copy) NSString *managerEmployeeId;
@property (nullable, nonatomic, copy) NSString *managerName;
@property (nullable, nonatomic, copy) NSString *managerRecordId;
@property (nullable, nonatomic, copy) NSString *metricSystem;
@property (nullable, nonatomic, copy) NSString *middleName;
@property (nullable, nonatomic, copy) NSString *mobilePhoneNumber;
@property (nullable, nonatomic, copy) NSString *nationalIdentifier;
@property (nullable, nonatomic, copy) NSString *nextStep;
@property (nullable, nonatomic, copy) NSString *notifyGroupName;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSString *referal;
@property (nullable, nonatomic, copy) NSString *salesTaxRateRecordId;
@property (nullable, nonatomic, copy) NSString *salutation;
@property (nullable, nonatomic, copy) NSNumber *sendGPSLocation;
@property (nullable, nonatomic, copy) NSString *sex;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *surname;
@property (nullable, nonatomic, copy) NSString *territory;
@property (nullable, nonatomic, copy) NSString *timerAutoSync;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *userGroupName;
@property (nullable, nonatomic, copy) NSString *userIdent;
@property (nullable, nonatomic, copy) NSString *userNotes1;
@property (nullable, nonatomic, copy) NSString *userNotes2;
@property (nullable, nonatomic, copy) NSString *userNumber;
@property (nullable, nonatomic, copy) NSString *userType;
@property (nullable, nonatomic, copy) NSString *value;
@property (nullable, nonatomic, copy) NSString *workPhoneNumber;
@property (nullable, nonatomic, copy) NSString *zip;
@property (nullable, nonatomic, copy) NSString *quota;

@end

NS_ASSUME_NONNULL_END
