//
//  TrainingBreakLocation+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 4/2/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "TrainingBreakLocation+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation TrainingBreakLocation

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

    //9 HeaderObjectId
    [result addObject:[self getUploadCodingFieldFomValue:self.headerObjectId]];

    //10 HeaderObjectType
    [result addObject:[self getUploadCodingFieldFomValue:self.headerObjectType]];

    //11 HeaderObjectBarcode
    [result addObject:[self getUploadCodingFieldFomValue:self.headerBarcode]];

    //12 Title
    [result addObject:[self getUploadCodingFieldFomValue:self.title]];

    //13 Notes
    [result addObject:[self getUploadCodingFieldFomValue:self.notes]];

    //14 Location
    [result addObject:[self getUploadCodingFieldFomValue:self.location]];

    //15 ItemType
    [result addObject:[self getUploadCodingFieldFomValue:self.itemType]];

    //16 Latitude
    [result addObject:[self getUploadCodingFieldFomValue:self.latitude]];

    //17 Longitude
    [result addObject:[self getUploadCodingFieldFomValue:self.longitude]];

    //18 Category
    [result addObject:[self getUploadCodingFieldFomValue:self.cat1]];

    //19 Student First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.firstName]];

    //20 Student Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.lastName]];

    //21 Driver License Number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];

    //22 Driver License State
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];

    //23 Instructor First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];

    //24 Instructor Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];

    //25 Instructor Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorEmployeeId]];

    // 26 Start DateTime
    [result addObject:[self rcoDateTimeString:self.startDateTime]];

    // 27 End DateTime
    [result addObject:[self rcoDateTimeString:self.endDateTime]];

    //28 Elapsed Minutes
    [result addObject:[self getUploadCodingFieldFomValue:self.elapsedMinutes]];

    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}
@end
