//
//  DriverTurn+CoreDataClass.m
//  MobileOffice
//
//  Created by .D. .D. on 3/25/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "DriverTurn+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation DriverTurn
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
    
    //10 Driving turn Type
    [result addObject:[self getUploadCodingFieldFomValue:self.turnType]];
    
    //11 Latitude
    [result addObject:[self getUploadCodingFieldFomValue:self.latitude]];
    
    //12 Longitude
    [result addObject:[self getUploadCodingFieldFomValue:self.longitude]];
    
    //13 Company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];
    
    //14 Employee First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentFirstName]];

    //15 Employee Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentLastName]];

    //16 Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeId]];

    //17 Instructor First Nmae
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];
    
    //18 Instriuctor last name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];
    
    //19 Instructor Id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorId]];
    
    //20 test header mobile record Id
    [result addObject:[self getUploadCodingFieldFomValue:self.masterMobileRecordId]];

    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

+(NSString*)getDateTimeEscapedFromDate:(NSDate*)dateTime {
    if (!dateTime) {
        return @"";
    }
    NSString *str = [NSDate rcoDateTimeString:dateTime];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    return str;
}


+(NSString*)imagePathForStudentRecordId:(NSString*)recordId andDateTime:(NSDate*)dateTime {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *layOutPath=[NSString stringWithFormat:@"%@/Turns",[paths objectAtIndex:0]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:layOutPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:layOutPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [layOutPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Turns_%@_%@.png", recordId, [DriverTurn getDateTimeEscapedFromDate:dateTime]]];
}

@end
