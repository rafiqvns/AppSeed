//
//  TrainingEquipmentReviewed+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 11/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingEquipmentReviewed+CoreDataClass.h"
#import "Settings.h"
#import "DataRepository.h"


@implementation TrainingEquipmentReviewed
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
    
    //10 Equipment type
    [result addObject:[self getUploadCodingFieldFomValue:self.equipmentType]];
    
    //11 Notes
    [result addObject:[self getUploadCodingFieldFomValue:self.notes]];

    //12 Company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];

    // 13 Student first name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentFirstName]];

    //14 Student Last name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentLastName]];

    //15 Student driver license number
    [result addObject:[self getUploadCodingFieldFomValue:self.studentDriverLicenseNumber]];
    
    //16 student driver license state
    [result addObject:[self getUploadCodingFieldFomValue:self.studentDriverLicenseState]];

    //17 Instructor first name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];

    //18 instructor last name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];
    
    //19 instructor employy id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorEmployeeId]];

    //20 Parent mobile record id
    [result addObject:[self getUploadCodingFieldFomValue:self.parentMobileRecordId]];

    //21 transmissionType
    [result addObject:[self getUploadCodingFieldFomValue:self.transmissionType]];

    //22 transmissionTypeNotes
    [result addObject:[self getUploadCodingFieldFomValue:self.transmissionTypeNotes]];

    //23 vehicleType
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleType]];

    //24 vehicleTypeNotes
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeNotes]];

    //25 vehicleManufacturer
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleManufacturer]];

    //26 vehicleManufacturerNotes
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleManufacturerNotes]];

    //27 singleTrailerLength
    [result addObject:[self getUploadCodingFieldFomValue:self.singleTrailerLength]];

    //28 singleTrailerNotes
    [result addObject:[self getUploadCodingFieldFomValue:self.singleTrailerNotes]];

    //29 lVCType
    [result addObject:[self getUploadCodingFieldFomValue:self.lVCType]];

    //30 lVCTypeNotes
    [result addObject:[self getUploadCodingFieldFomValue:self.lVCTypeNotes]];

    //31 lVCLength
    [result addObject:[self getUploadCodingFieldFomValue:self.lVCLength]];

    //32 lVCLengthNotes
    [result addObject:[self getUploadCodingFieldFomValue:self.lVCLengthNotes]];

    //33 dollyGearType
    [result addObject:[self getUploadCodingFieldFomValue:self.dollyGearType]];
    
    //34 dollyGearTypeNotes
    [result addObject:[self getUploadCodingFieldFomValue:self.dollyGearTypeNotes]];

    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
