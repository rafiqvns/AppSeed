//
//  TrainingScore+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 12/27/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingScore+CoreDataClass.h"
#import "Settings.h"
#import "DataRepository.h"

@implementation TrainingScore
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
    
    // 10 Company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];

    // 11 Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeId]];

    // 12 Student first name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentFirstName]];

    //13 Student Last name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentLastName]];

    //14 Student driver license number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];

    //15 Student driver license state
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];

    //16 Instructor first name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];

    //17 Instructor last name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];

    //18 Instructor employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorEmployeeId]];

    //19 tesst name
    [result addObject:[self getUploadCodingFieldFomValue:self.testName]];

    //20 section name
    [result addObject:[self getUploadCodingFieldFomValue:self.sectionName]];

    //21 elapsed time
    [result addObject:[self getUploadCodingFieldFomValue:self.elapsedTime]];

    //22 points received
    [result addObject:[self getUploadCodingFieldFomValue:self.pointsReceived]];

    //23 points possible
    [result addObject:[self getUploadCodingFieldFomValue:self.pointsPossible]];

    //24 MasterMobileRecordId
    [result addObject:[self getUploadCodingFieldFomValue:self.masterMobileRecordId]];

    //25 TestDataHeaderMobileRecordId
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoObjectParentId]];

    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
