//
//  AccidentVehicle+CoreDataClass.m
//  MobileOffice
//
//  Created by .D. .D. on 5/22/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentVehicle+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation AccidentVehicle
-(NSString*)CSVFormat {
    NSMutableArray *result = [NSMutableArray array];
    
    if ([self existsOnServer]) {
        [result addObject:@"U"];
        [result addObject:@"H"];
        [result addObject:self.rcoObjectId];
        [result addObject:self.rcoObjectType];
    } else {
        [result addObject:@"O"];
        [result addObject:@"H"];
        [result addObject:@""];
        [result addObject:@""];
    }
    
    //5 MobileRecordId
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoMobileRecordId]];
    
    //6 functionalGroupName
    [result addObject:@""];
    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];
    
    // 7 organisation name
    [result addObject:organizationName];
    
    //8 organisation number
    [result addObject:organizationId];
    
    //9 Date
    if (self.dateTime) {
        [result addObject:[self rcoDateTimeString:self.dateTime]];
    } else {
        [result addObject:@""];
    }
    
    //10 Master Barcode ( the link with the parent)
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoBarcodeParent]];

    //11 Driver first name
    [result addObject:[self getUploadCodingFieldFomValue:self.firstName]];

    //12 Driver last name
    [result addObject:[self getUploadCodingFieldFomValue:self.lastName]];

    //13 driver license number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];

    //14 driver license state
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];

    //15 driver license expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseExpirationDate]];

    //16 driver address
    [result addObject:[self getUploadCodingFieldFomValue:self.address1]];

    //17 driver city
    [result addObject:[self getUploadCodingFieldFomValue:self.city]];

    //18 driver state
    [result addObject:[self getUploadCodingFieldFomValue:self.state]];

    //19 driver zipcode
    [result addObject:[self getUploadCodingFieldFomValue:self.zip]];

    //20 driver license class
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseClass]];

    //21 driver home phone
    [result addObject:[self getUploadCodingFieldFomValue:self.homePhone]];

    //22 driver work phone
    [result addObject:[self getUploadCodingFieldFomValue:self.workPhone]];

    //23 driver mobile phone
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilePhone]];

    //24 vehice type
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleType]];

    //25 vehice make
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleMake]];

    //26 vehice model
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleModel]];

    //27 vehice year
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleYear]];

    //28 cpmbination vehicle
    [result addObject:[self getUploadCodingFieldFomValue:self.combinationVehicle]];
    
    //29 description of damages
    [result addObject:[self getUploadCodingFieldFomValue:self.descriptionOfDamage]];
    
    //30 license plate number
    [result addObject:[self getUploadCodingFieldFomValue:self.number]];

    //31 insurance company
    [result addObject:[self getUploadCodingFieldFomValue:self.insuranceCompany]];

    //32 insurance agent
    [result addObject:[self getUploadCodingFieldFomValue:self.insuranceAgent]];

    //33 insurance phone number
    [result addObject:[self getUploadCodingFieldFomValue:self.insurancePhone]];
    
    //34 insurance police number
    [result addObject:[self getUploadCodingFieldFomValue:self.insurancePolicyNumber]];

    //35 insurance expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.insuranceExpirationDate]];
    
    //36 insurance address
    [result addObject:[self getUploadCodingFieldFomValue:self.insuranceAddress]];

    //37 insurance city
    [result addObject:[self getUploadCodingFieldFomValue:self.insuranceCity]];

    //38 insurance state
    [result addObject:[self getUploadCodingFieldFomValue:self.insuranceState]];

    //39 insurance zipcode
    [result addObject:[self getUploadCodingFieldFomValue:self.insuranceZipcode]];
    
    //40 insured by driver
    [result addObject:[self getUploadCodingFieldFomValue:self.insuredByDriver]];

    //41 registration number
    [result addObject:[self getUploadCodingFieldFomValue:self.registrationNumber]];

    //42 registration expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.registrationExpirationDate]];

    //43 registration name
    [result addObject:[self getUploadCodingFieldFomValue:self.registrationName]];

    //44 registration addres
    [result addObject:[self getUploadCodingFieldFomValue:self.registrationAddress]];

    //45 registration city
    [result addObject:[self getUploadCodingFieldFomValue:self.registrationCity]];

    //46 registration state
    [result addObject:[self getUploadCodingFieldFomValue:self.registrationState]];

    //47 registration zipcode
    [result addObject:[self getUploadCodingFieldFomValue:self.registrationZipcode]];

    //48 employed by
    [result addObject:[self getUploadCodingFieldFomValue:self.employedBy]];

    //49 assigned location
    [result addObject:[self getUploadCodingFieldFomValue:self.assignedLocation]];

    //50 cpmpany address
    [result addObject:[self getUploadCodingFieldFomValue:self.companyAddress]];

    //51 cpmpany city
    [result addObject:[self getUploadCodingFieldFomValue:self.companyCity]];

    //52 cpmpany state
    [result addObject:[self getUploadCodingFieldFomValue:self.companyState]];
    
    //53 company zipcode
    [result addObject:[self getUploadCodingFieldFomValue:self.companyZipcode]];

    //54 company phone number
    [result addObject:[self getUploadCodingFieldFomValue:self.companyPhone]];

    //55 notes
    [result addObject:[self getUploadCodingFieldFomValue:self.notes]];

    //56 date of birth
    [result addObject:[self getUploadCodingFieldFomValue:self.dateofBirth]];

    //57 VIN
    [result addObject:[self getUploadCodingFieldFomValue:self.vin]];

    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
