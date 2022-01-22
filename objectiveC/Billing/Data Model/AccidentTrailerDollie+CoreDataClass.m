//
//  AccidentTrailerDollie+CoreDataClass.m
//  MobileOffice
//
//  Created by .D. .D. on 5/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentTrailerDollie+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation AccidentTrailerDollie
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

    //11 Trailer Make
    [result addObject:[self getUploadCodingFieldFomValue:self.trailerMake]];

    //12 Trailer Size
    [result addObject:[self getUploadCodingFieldFomValue:self.trailerSize]];

    //13 Registration Current
    [result addObject:[self getUploadCodingFieldFomValue:self.registrationCurrent]];

    //14 Inspection Current
    [result addObject:[self getUploadCodingFieldFomValue:self.inspectionCurrent]];

    //15 License Plate Number
    [result addObject:[self getUploadCodingFieldFomValue:self.licensePlateNumber]];

    //16 License State
    [result addObject:[self getUploadCodingFieldFomValue:self.licenseState]];

    //17 Notes
    [result addObject:[self getUploadCodingFieldFomValue:self.notes]];

    //18 Dolly Type
    [result addObject:[self getUploadCodingFieldFomValue:self.dollyType]];
    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
