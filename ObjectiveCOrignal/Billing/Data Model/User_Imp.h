//
//  User_Imp.h
//  Mobile Office
//
//  Created by .R.H. on 10/12/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "User.h"

#define kUserJobTypeSales @"sales"

#define UserDriverRole @"Driver"
#define UserNormalRole @"NormalUser"
#define UserDriverRoleCSD @"Driver_CSD"

#define DutyStatusPersonal @"personal"
#define DutyStatusYardMoves @"yard moves"


#define LaborStatusWorking @"working"
#define LaborStatusBreak @"break"
#define LaborStatusVacation @"vacation"
#define LaborStatusSick @"sick"
#define LaborStatusHoliday @"holiday"
#define LaborStatusMaternity @"maternity"
#define LaborStatusOffDuty @"off"

#define UserFunctionalGroupRecords @"functionalGroupRecords"
#define UserWithDriverLicenseNumberAnState @"UserWithDriverLicenseNumberAnState"
#define UserGroupRecords @"userGroupRecords"

@interface User (User_Imp)

- (NSString *) Name;
- (NSString *) FistNameLastName;
- (NSString *) constructedName;
- (NSString *) constructedAddress;
- (NSString *) constructedAddressSingleLine;
- (NSString *) constructedAddressDoubleLine;
- (NSString *) constructedNumber;
- (NSString *) constructedNameAndCompany;

- (NSString *) fullInfo;

- (NSString *) Address;
- (NSString *) AddressFull;
- (NSString *) CityStateZip;

- (NSString *) HTMLFormat;

- (NSString*)FirstNameLastName;

- (NSString*) fullNameForHTMLInvoice;

- (BOOL)companyContainsFirtNameAndLastName;

- (NSString*)CSVFormat;

- (NSString*)getUserGroupName;

- (BOOL)isDriver;

- (BOOL)dutyStatusPersonalAvailable;

- (BOOL)dutyStatusYardMovesAvailable;

+ (NSString*)objectGrowerFilterKey;
+ (NSString*)objectVendorFilterKey;

-(UIColor*)getStatusColor:(NSString*)status;

-(NSString*)exportApproved;

@end
