//
//  AccidentWitness+CoreDataClass.m
//  MobileOffice
//
//  Created by .D. .D. on 5/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentWitness+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation AccidentWitness
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
    
    //10 MasterBarcode
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoBarcodeParent]];

    //11 First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.firstName]];

    //12 Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.lastName]];

    //13 Driver License Number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];

    //14 Home Phone Number
    [result addObject:[self getUploadCodingFieldFomValue:self.homePhone]];
    
    //15 Work Phone Number
    [result addObject:[self getUploadCodingFieldFomValue:self.workPhone]];

    //16 Mobile Phone Number
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilePhone]];

    //17 Notes
    [result addObject:[self getUploadCodingFieldFomValue:self.notes]];
    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
