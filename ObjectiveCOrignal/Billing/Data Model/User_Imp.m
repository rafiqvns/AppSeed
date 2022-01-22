//
//  User.m
//  Billing2
//
//  Created by .R.H. on 10/12/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "User_Imp.h"
#import "RCOObject+RCOObject_Imp.h"
#import "DataRepository.h"
#import "Settings.h"


@implementation User (User_Imp)

- (NSString *) Name
{
    NSMutableArray *fields = [NSMutableArray array];
    
    if ([self.surname length]) {
        [fields addObject:self.surname];
    }
    if ([self.firstname length]) {
        [fields addObject:self.firstname];
    }
    
    if ([fields count]) {
        return [fields componentsJoinedByString:@" "];
    } else {
        return @"";
    }
}

- (NSString *) FistNameLastName
{
    NSMutableArray *fields = [NSMutableArray array];
    
    if ([self.surname length] >0) {
        [fields addObject:self.surname];
    }
    if ([self.firstname length] >0) {
        [fields addObject:self.firstname];
    }
    
    if ([fields count]) {
        return [fields componentsJoinedByString:@" "];
    } else {
        return @"";
    }
}


- (NSString *) constructedName
{
 
    NSString *theText = @"";
    NSString *theCompany = self.company;
    
    if ([theCompany length] ) {
        theText = [NSString stringWithFormat: @"%@", self.company];
    } else {
        if(self.firstname !=nil ) theText = [NSString stringWithFormat: @"%@ ", self.firstname];
        if(self.surname !=nil ) theText = [NSString stringWithFormat: @"%@%@ ", theText, self.surname];
    }
    
    return theText;
    
    /*
    NSMutableArray *fields = [NSMutableArray array];
    
    if ([self.company length] > 0) {
        [fields addObject:self.company];
    }
    
    if ([self.firstname length] > 0) {
        [fields addObject:self.firstname];
    }
    
    if ([self.surname length] > 0) {
        [fields addObject:self.surname];
    }
    
    if ([fields count] == 0) {
        return @"";
    } else {
        return [fields componentsJoinedByString:@", "];
    }
    */
}

- (NSString *) constructedNameAndCompany
{
     NSMutableArray *fields = [NSMutableArray array];
     
     if ([self.company length] > 0) {
     [fields addObject:self.company];
     }
     
     if ([self.firstname length] > 0) {
     [fields addObject:self.firstname];
     }
     
     if ([self.surname length] > 0) {
     [fields addObject:self.surname];
     }
     
     if ([fields count] == 0) {
         return @"";
     } else {
         return [fields componentsJoinedByString:@", "];
     }
}


-(NSString*)FirstNameLastName {
    NSString *theText = @"";
    
    if(self.firstname !=nil ) theText = [NSString stringWithFormat: @"%@ ", self.firstname];
    if(self.surname !=nil ) theText = [NSString stringWithFormat: @"%@%@ ", theText, self.surname];
    
    return theText;

}

- (NSString *) constructedAddress
{
    NSString *address=@"";
    if(self.address1 != nil && self.address2 != nil )
    {
        address = [NSString stringWithFormat:@"%@\n%@",self.address1, self.address2];
    }
    else if (self.address1 != nil )
    {
        address = self.address1;
    }
    NSString *citystate=@"";
    if([self.city length] && [self.state length] )
    {
        citystate = [NSString stringWithFormat:@"%@, %@",self.city, self.state];
    }
    else if (self.city != nil )
    {
        citystate = self.city;
    }
    else if (self.state != nil )
    {
        citystate = self.state;
    }
        
    NSString *theText = [NSString stringWithFormat:@"%@\n%@ %@\n%@", address,citystate, self.zip, self.phone];
    theText = [theText stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    return theText;
}

- (NSString *) fullInfo {
    NSMutableArray *lines = [NSMutableArray array];
    
    if (![self companyContainsFirtNameAndLastName]) {
        if ([self.company length]) {
            [lines addObject:self.company];
        }
    } else {
        NSLog(@"company does not contain first name and last name");
    }
    
    if ([self.firstname length] || [self.surname length]) {
        NSMutableString *name = [NSMutableString string];
        
        if ([self.firstname length]) {
            if (![lines containsObject:self.firstname]) {
                [name appendString:self.firstname];
            }
        }
        if ([self.surname length]) {
            if ([name length] > 0) {
                if (![lines containsObject:self.surname]) {
                    [name appendString:@", "];
                    [name appendString:self.surname];
                }
            } else {
                if (![lines containsObject:self.surname]) {
                    [name appendString:self.surname];
                }
            }
        }
    
        if ([name length] > 0) {
            [lines addObject:name];
        }
    }
    
    if ([self.address1 length]) {
        [lines addObject:self.address1];
    }

    if ([self.address2 length]) {
        [lines addObject:self.address2];
    }

    if (self.city || self.state || self.zip) {
        NSMutableArray *address = [NSMutableArray array];
        if ([self.city length]) {
            [address addObject:self.city];
        }
        
        if ([self.state length]) {
            [address addObject:self.state];
        }
    
        if ([self.zip length]) {
            [address addObject:self.zip];
        }
    
        if ([address count]) {
            [lines addObject:[address componentsJoinedByString:@" "]];
        }
    }
    
    if ([self.phone length]) {
        [lines addObject:self.phone];
    }
    
    if ([self.email length]) {
        [lines addObject:self.email];
    }

    if (lines.count > 0) {
        return [lines componentsJoinedByString:@"\n"];
    } else {
        return @"";
    }
}


-(BOOL)companyContainsFirtNameAndLastName {
    
    if (([self.firstname length] && [self.surname length]) && ([self.company rangeOfString:self.firstname].length && [self.company rangeOfString:self.surname].length)) {
        
        return YES;
    }
    return NO;
}

- (NSString *) constructedAddressDoubleLine
{
    NSString *address=@"";
    if(self.address1 != nil && self.address2 != nil )
    {
        address = [NSString stringWithFormat:@"%@\n%@",self.address1, self.address2];
    }
    else if (self.address1 != nil )
    {
        address = self.address1;
    }
    NSString *citystate=@"";
    if([self.city length] && [self.state length] )
    {
        citystate = [NSString stringWithFormat:@"%@, %@",self.city, self.state];
    }
    else if (self.city != nil )
    {
        citystate = self.city;
    }
    else if (self.state != nil )
    {
        citystate = self.state;
    }
    
    NSString *theText = [NSString stringWithFormat:@"%@ %@ %@ %@", address,citystate, self.zip, self.phone];
    theText = [theText stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    return theText;
}

- (NSString *) constructedAddressSingleLine
{
    NSString *address= [self constructedAddressDoubleLine];
    address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    return address;
}


- (NSString *) Address {
    NSString *address = @"";
    if ([self.address1 length] && [self.address2 length]) {
        address = [NSString stringWithFormat:@"%@ %@",self.address1, self.address2];
    }
    else if ([self.address1 length])
    {
        address = self.address1;
    }
    else if ([self.address2 length])
    {
        address = self.address2;
    }
    
    return address;
}

- (NSString *) AddressFull {
    NSMutableArray *comp = [NSMutableArray array];
    NSString *val = [self Address];
    
    if ([val length]) {
        [comp addObject:val];
    }
    
    val = [self CityStateZip];
    if ([val length]) {
        [comp addObject:val];
    }
    
    if ([comp count]) {
        return [comp componentsJoinedByString:@", "];
    }
    return @"";
}

- (NSString *) CityStateZip {
    
    NSString *citystate = @"";
    
    NSMutableArray *comp = [NSMutableArray array];
    
    if([self.city length] && [self.state length] )
    {
        citystate = [NSString stringWithFormat:@"%@ %@",self.city, self.state];
    }
    else if ([self.city length])
    {
        citystate = self.city;
    }
    else if ([self.state length])
    {
        citystate = self.state;
    }
    
    if ([citystate length]) {
        citystate = [citystate stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        [comp addObject:citystate];
    }
    
    if ([self.zip length]) {
        [comp addObject:self.zip];
    }
    
    NSString *theText = nil;
    
    if ([comp count]) {
        theText = [comp componentsJoinedByString:@" "];
    }
    
    return theText; 
}

- (NSString *) constructedNumber
{
    if(self.userNumber !=nil ) 
        return self.userNumber;
    else
        return @"";
}

- (NSString *) HTMLFormat {
    
    NSMutableString * HTMLString = [NSMutableString string];

    [HTMLString appendFormat:@"<HTML><BODY><TABLE WIDTH=100%% BORDER=0 CELLPADDING=4 CELLSPACING=0>"];
    if ([self.company length] > 0) {
        [HTMLString appendFormat:@"%@", [self addRow:@"Company:" withValue:self.company]];
    }
    if ([self.address1 length] > 0) {
        [HTMLString appendFormat:@"%@", [self addRow:@"Address1:" withValue:self.address1]];
    }
    if ([self.address2 length] > 0) {
        [HTMLString appendFormat:@"%@", [self addRow:@"Address2:" withValue:self.address2]];
    }
    if ([self.url length] > 0) {
        [HTMLString appendFormat:@"%@", [self addRow:@"Website::" withValue:self.url]];
    }
    
    [HTMLString appendFormat:@"%@", [self addRow:@"First Name:" withValue:self.firstname]];
    [HTMLString appendFormat:@"%@", [self addRow:@"Last Name:" withValue:self.surname]];
    
    if ([self.email length] > 0) {
        [HTMLString appendFormat:@"%@", [self addRow:@"Email:" withValue:self.email]];
    }
    if ([self.phone length] > 0) {
        [HTMLString appendFormat:@"%@", [self addRow:@"Phone:" withValue:self.phone]];
    }
    if ([self.userNotes1 length] > 0) {
        [HTMLString appendFormat:@"%@", [self addRow:@"Notes1:" withValue:self.userNotes1]];
    }
    if ([self.userNotes2 length] > 0) {
        [HTMLString appendFormat:@"%@", [self addRow:@"Notes2:" withValue:self.userNotes2]];
    }
    
    if ([self.itemType isEqualToString:@"prospect"]) {
        if ([self.budget length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Budget:" withValue:self.budget]];
        }
        /*
        if ([self.competitors length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Competitors:" withValue:self.competitors]];
        }
        if ([self.evaluators length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Evaluators:" withValue:self.evaluators]];
        }
        if ([self.approvers length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Approvers:" withValue:self.approvers]];
        }
        */
        if ([self.detractors length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Detractors:" withValue:self.detractors]];
        }
        if ([self.detractors length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Detractors:" withValue:self.detractors]];
        }
        /*
        if ([self.supporters length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Supporters:" withValue:self.supporters]];
        }
        */
        if ([self.nextStep length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Next Steps:" withValue:self.nextStep]];
        }
        if ([self.value length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Value:" withValue:self.value]];
        }
    } else if ([self.itemType isEqualToString:@"lead"]) {
        if ([self.leadSource length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Lead Source:" withValue:self.leadSource]];
        }
        if ([self.referal length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Referal:" withValue:self.referal]];
        }
        if ([self.growth length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Growth:" withValue:self.growth]];
        }
        /*
        if ([self.followup length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Followup:" withValue:self.followup]];
        }
        */
        if ([self.value length] > 0) {
            [HTMLString appendFormat:@"%@", [self addRow:@"Value:" withValue:self.value]];
        }
    }
    
    [HTMLString appendFormat:@"</TABLE></BODY></HTML>"];
    return HTMLString;
}

-(NSString*)addRow:(NSString*)title withValue:(NSString*)value {
    NSMutableString * HTMLRowString = [NSMutableString string];
    [HTMLRowString appendFormat:@"<TR VALIGN=TOP HEIGHT=10><TD WIDTH=25%% HEIGHT=22><p><b>%@</b></p></TD><TD WIDTH=75%% HEIGHT=22><p>%@</p></TD></TR>", title, value];
    return HTMLRowString;
}

- (NSString*) fullNameForHTMLInvoice {
    NSString *name = @"";
    
    NSString *text = nil;
    
    NSMutableArray *nameArray = [NSMutableArray array];
    
    NSString *constructedName = [NSString stringWithFormat:@"%@, %@", self.surname, self.firstname];
    
    if ([constructedName isEqualToString:self.company]) {
        NSLog(@"Name is the same");
        if ([self.company length] > 0) {
            name = self.company;
        }

    } else {
        
        if ([self.company length] > 0) {
            name = [NSString stringWithFormat:@"%@<br>", self.company];
        }
        
        if ([self.surname length] > 0) {
            [nameArray addObject:self.surname];
        }
        
        if ([self.firstname length] > 0) {
            [nameArray addObject:self.firstname];
        }
        
        if ([nameArray count] > 0) {
            name = [NSString stringWithFormat:@"%@%@", name, [nameArray componentsJoinedByString:@", "]];
        } 

    }
        
    name = [name stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    text = [NSString stringWithFormat:@"%@", name];
    
    return text;
}

- (NSString*)CSVFormat {
    NSMutableArray *result = [NSMutableArray array];
    
    //objectId + objectType
    if ([self existsOnServer]) {
        [result addObject:@"U"];
        [result addObject:@"H"];
        [result addObject:self.rcoObjectId];
        if (self.rcoObjectClass) {
            [result addObject:self.rcoObjectType];
        }
        
    } else {
        [result addObject:@"O"];
        [result addObject:@"H"];
        [result addObject:@""];
        [result addObject:@""];
    }
    
    // 5
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoMobileRecordId]];
    
    NSString *functionalGroupName = [[DataRepository sharedInstance].functionalRecordTypeMap objectForKey:@"User"];
    
    /*
     19.05.2015
     we should not create users under Managers node from Settings->User Group Map
    */
    // 6
    functionalGroupName = @"";
    
    if (functionalGroupName.length) {
        [result addObject:functionalGroupName];
    }
    else {
        [result addObject:@""];
    }
    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];

    NSString *currentLoginUserRecordId  = [[DataRepository sharedInstance] getLoggedUserRecordId];

    // 7 Role
    if ([self.itemType isEqualToString:kUserTypeStudent] && [organizationId isEqualToString:@"28"]) {
        // 28.06.2019 for CSD organization when we create students we should set the role to the Driver-CSD
        [result addObject:UserDriverRoleCSD];
    } else if ([self.itemType isEqualToString:kUserTypeDriver]) {
        // we should get the role
        NSArray *roles = [[DataRepository sharedInstance] getUserRoles];
        NSString *role = nil;
        if ([roles count]) {
            role = [roles objectAtIndex:0];
        }
        if ([role length]) {
            NSLog(@"Current Role:%@-----Driving Role is%@", role, UserDriverRole);
            [result addObject:role];
        } else {
            [result addObject:UserDriverRole];
        }
    } else {
        if ([self.rcoRecordId isEqualToString:currentLoginUserRecordId]) {

            // we are doing an update
            
            NSArray *roles = [[DataRepository sharedInstance] getUserRoles];
            NSString *role = nil;
            
            if ([roles count]) {
                role = [roles objectAtIndex:0];
            }
            
            if ([role length]) {
                NSLog(@"Current Role:%@", role);
                [result addObject:role];
            } else {
                [result addObject:UserNormalRole];
            }
        } else {
            // new insert
            [result addObject:UserNormalRole];
        }
    }
    
    // 8 Login
    if ([self.rcoRecordId isEqualToString:currentLoginUserRecordId]) {
        // we should use the login user record id
        NSString *currentUserLogin = [[DataRepository sharedInstance] userName];
        if (!currentUserLogin) {
            return nil;
        }
        [result addObject:currentUserLogin];
        
    } else if ([self.email length] > 0) {
        [result addObject:self.email];
    } else {
        if ([self.itemType isEqualToString:kUserTypeLabor]) {
            // we should allow empty email for labor user
            if ([self.rcoRecordId length]) {
                [result addObject:self.rcoRecordId];
            } else {
                [result addObject:@"[[userrecordid]]"];
            }
        } else {
            // if the user is not labor then we should not allow to create it without having an email set
            return nil;
        }
    }
    
    // 9 Password
    if ([self.password length] == 0) {
        return nil;
    }
    
    [result addObject:self.password];
    
    // 10 Organization Name
    [result addObject:organizationName];
    
    // 11 Organization Number
    [result addObject:organizationId];
    
    // 12 User Group Name
    [result addObject:[self getUploadCodingFieldFomValue:self.userGroupName]];

    // 13 Company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];
    
    // 14 Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.surname]];
    
    // 15 First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.firstname]];
    
    // 16 Address 1
    [result addObject:[self getUploadCodingFieldFomValue:self.address1]];

    // 17 Address 2
    [result addObject:[self getUploadCodingFieldFomValue:self.address2]];

    // 18 city
    [result addObject:[self getUploadCodingFieldFomValue:self.city]];

    // 19 state
    [result addObject:[self getUploadCodingFieldFomValue:self.state]];

    // 20 zipcode
    [result addObject:[self getUploadCodingFieldFomValue:self.zip]];

    // 21 country
    [result addObject:[self getUploadCodingFieldFomValue:self.country]];

    // 22 email
    [result addObject:[self getUploadCodingFieldFomValue:self.email]];

    // 23 phome
    [result addObject:[self getUploadCodingFieldFomValue:self.phone]];

    // 24 item type
    [result addObject:[self getUploadCodingFieldFomValue:self.itemType]];

    // 25 Latitude
    [result addObject:[NSString stringWithFormat:@"%@", self.latitude]];
    
    // 26 Longitude
    [result addObject:[NSString stringWithFormat:@"%@", self.longitude]];

    // 27 driver license number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];

    // 28 driver license state
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];

    // 29 location
    [result addObject:[self getUploadCodingFieldFomValue:self.location]];

    // 30 customer number
    [result addObject:[self getUploadCodingFieldFomValue:self.customerNumber]];

    // 31 date of hire
    [result addObject:[self getUploadCodingFieldFomValue:self.dateOfHire]];

    // 32 date of birth
    [result addObject:[self getUploadCodingFieldFomValue:self.dateOfBirth]];
 
    // 33 user type
    [result addObject:[self getUploadCodingFieldFomValue:self.userType]];

    // 34 Employee number
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeNumber]];
    
    // 35 Status
    [result addObject:[self getUploadCodingFieldFomValue:self.status]];
    
    // 36 Sex
    [result addObject:[self getUploadCodingFieldFomValue:self.sex]];

    // 37 National Identifier
    [result addObject:[self getUploadCodingFieldFomValue:self.nationalIdentifier]];

    // 38 Contact name
    [result addObject:[self getUploadCodingFieldFomValue:self.contactName]];

    // 39 Middle name
    [result addObject:[self getUploadCodingFieldFomValue:self.middleName]];

    // 40 Driver License class
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseClass]];

    // 41 Endorsements
    [result addObject:[self getUploadCodingFieldFomValue:self.endorsements]];

    // 42 driverLicenseExpirationDate
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseExpirationDate]];

    // 43 dOTExpirationDate
    [result addObject:[self getUploadCodingFieldFomValue:self.dOTExpirationDate]];

    // 44 correctiveLensRequired
    [result addObject:[self getUploadCodingFieldFomValue:self.correctiveLensRequired]];

    // 45 category1Name
    [result addObject:[self getUploadCodingFieldFomValue:self.category1Name]];

    // 46 category1Value
    [result addObject:[self getUploadCodingFieldFomValue:self.category1Value]];

    // 47 category2Name
    [result addObject:[self getUploadCodingFieldFomValue:self.category2Name]];
    
    // 48 category2Value
    [result addObject:[self getUploadCodingFieldFomValue:self.category2Value]];

    // 49 category3Name
    [result addObject:[self getUploadCodingFieldFomValue:self.category3Name]];

    // 50 category3Value
    [result addObject:[self getUploadCodingFieldFomValue:self.category3Value]];

    // 51 category4Name
    [result addObject:[self getUploadCodingFieldFomValue:self.category4Name]];
    
    // 52 category4Value
    [result addObject:[self getUploadCodingFieldFomValue:self.category4Value]];

    // 53 category5Name
    [result addObject:[self getUploadCodingFieldFomValue:self.category5Name]];
    
    // 54 category5Value
    [result addObject:[self getUploadCodingFieldFomValue:self.category5Value]];

    // 55 category6Name
    [result addObject:[self getUploadCodingFieldFomValue:self.category6Name]];
    
    // 56 category6Value
    [result addObject:[self getUploadCodingFieldFomValue:self.category6Value]];

    // 57 mobilePhoneNumber
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilePhoneNumber]];

    // 58 homePhoneNumber
    [result addObject:[self getUploadCodingFieldFomValue:self.homePhoneNumber]];

    // 59 homePhoneNumber
    [result addObject:[self getUploadCodingFieldFomValue:self.workPhoneNumber]];

    // 60  notify group name
    [result addObject:[self getUploadCodingFieldFomValue:self.notifyGroupName]];
    
    // 61 Rating
    
    // 62 Number of reviews
    
    // 63 Quota
    
    // 64 Manager Name
    
    // 65 ManagerRecordId
    
    // 66 manager Employee Id
    
    // 67 Territory

    return [result componentsJoinedByString:@"\",\""];
}

- (NSString*)getUserGroupName {
    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];

    NSString *userGroup = @"";
    
    if ([self.itemType isEqualToString:kUserTypeCustomer]) {
        userGroup = @"Customers";
    }
    else
    if ([self.itemType isEqualToString:@"vendor"]) {
        userGroup = @"Vendors";
    }
    else
    if ([self.itemType isEqualToString:kUserTypeStaff]) {
        userGroup = @"Employees";
    }
    else
    if ([self.itemType isEqualToString:@"dealer"]) {
        userGroup = @"Dealers";
    }
    else
    if ([self.itemType isEqualToString:@"prospect"]) {
        userGroup = @"Prospects";
    }
    else
    if ([self.itemType isEqualToString:@"lead"]) {
        userGroup = @"Leads";
    }
    else
    if ([self.itemType isEqualToString:kUserTypeTechnician]) {
        userGroup = @"Technicians";
    }
    else
    if ([self.itemType isEqualToString:kUserTypeLabor]) {
        userGroup = @"Labor";
    }
    else if ([self.itemType isEqualToString:kUserTypeDriver]) {
        userGroup = @"Drivers";
    }
    else if ([self.itemType isEqualToString:kUserTypeStudent]) {
        userGroup = @"Students";
    }

    NSString *groupName = [NSString stringWithFormat:@"%@ %@", organizationName, userGroup];
    
    return groupName;
}

- (BOOL)isDriver {
    if ([self.itemType isEqualToString:kUserTypeDriver]) {
        return YES;
    }
    return NO;
}

- (BOOL)dutyStatusPersonalAvailable {
    return [self.driverDutyStatus containsString:DutyStatusPersonal];
}

- (BOOL)dutyStatusYardMovesAvailable {
    return [self.driverDutyStatus containsString:DutyStatusYardMoves];
}

+ (NSString*)objectGrowerFilterKey {
    return @"Grower";
}

+ (NSString*)objectVendorFilterKey {
    return @"Vendor";
}

-(UIColor*)getStatusColor:(NSString*)status {
    
    if ([status.lowercaseString isEqualToString:LaborStatusWorking]) {
        return [UIColor greenColor];
    }
    if ([status.lowercaseString isEqualToString:LaborStatusBreak]) {
        return [UIColor yellowColor];
    }
    if ([status.lowercaseString isEqualToString:LaborStatusVacation]) {
        return [UIColor orangeColor];
    }
    if ([status.lowercaseString isEqualToString:LaborStatusSick]) {
        return [UIColor blueColor];
    }
    if ([status.lowercaseString isEqualToString:LaborStatusHoliday]) {
        return [UIColor blackColor];
    }
    if ([status.lowercaseString isEqualToString:LaborStatusMaternity]) {
        return [UIColor grayColor];
    }
    if ([status.lowercaseString isEqualToString:LaborStatusOffDuty]) {
        return [UIColor lightGrayColor];
    }
    // default
    return [UIColor darkTextColor];
}

-(NSString*)exportApproved {
    return self.budget;
}

@end

