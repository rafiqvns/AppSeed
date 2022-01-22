//
//  EyeMovement+CoreDataClass.m
//  MobileOffice
//
//  Created by .D. .D. on 4/15/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "EyeMovement+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation EyeMovement
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
    
    //10 Company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];

    //11 Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.studentEmployeeId]];

    //12 Employee First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentFirstName]];
    
    //13 Employee Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentLastName]];
    
    // 14 Driver License Number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];
    
    // 15 Driver license State
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];

    //16 Instructor First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];
    
    //17 Instructor Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];
    
    //18 Instructor Id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorEmployeeId]];

    //19 Eye movement
    [result addObject:[self getUploadCodingFieldFomValue:self.eyeMovement]];

    //20 master mobil erecordId
    [result addObject:[self getUploadCodingFieldFomValue:self.masterMobileRecordId]];

    //21 Finish Time
    [result addObject:[self getUploadCodingFieldFomDateTime:self.finishDateTime]];

    //22 Front Conter
    [result addObject:[self getUploadCodingFieldFomValue:self.frontCounter]];

    //23 left Mirror Counter
    [result addObject:[self getUploadCodingFieldFomValue:self.leftMirrorCounter]];

    //24 rear counter
    [result addObject:[self getUploadCodingFieldFomValue:self.rearCounter]];

    //25 right Mirror Counter
    [result addObject:[self getUploadCodingFieldFomValue:self.rightMirrorCounter]];

    //26 Start Times
    [result addObject:[self getUploadCodingFieldFomValue:self.startTimes]];

    //27 Stop Times
    [result addObject:[self getUploadCodingFieldFomValue:self.stopTimes]];

    //28 Follow time counter
    [result addObject:[self getUploadCodingFieldFomValue:self.followTimeCounter]];

    //29 Parked cars
    [result addObject:[self getUploadCodingFieldFomValue:self.parkedCarsCounter]];

    //30 Gauges Counter
    [result addObject:[self getUploadCodingFieldFomValue:self.gaugesCounter]];

    //31 Eye Lead counter
    [result addObject:[self getUploadCodingFieldFomValue:self.eyeLeadCounter]];

    //32 Pedestrians Counter
    [result addObject:[self getUploadCodingFieldFomValue:self.pedestriansCounter]];

    //33 Intersections Counter
    [result addObject:[self getUploadCodingFieldFomValue:self.intersectionsCounter]];

    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
