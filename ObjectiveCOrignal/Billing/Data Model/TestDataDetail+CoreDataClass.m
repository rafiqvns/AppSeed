//
//  TestDataDetail+CoreDataClass.m
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TestDataDetail+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"


@implementation TestDataDetail
-(NSString*)CSVFormat {
    NSMutableArray *result = [NSMutableArray array];
    
    if ([self existsOnServer]) {
        [result addObject:@"U"];
        [result addObject:@"D"];
        [result addObject:self.rcoObjectId];
        [result addObject:self.rcoObjectType];
    } else {
        [result addObject:@"O"];
        [result addObject:@"D"];
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

    //10 Test Item Name
    [result addObject:[self getUploadCodingFieldFomValue:self.testItemName]];
    
    //11 Test Item Number
    [result addObject:[self getUploadCodingFieldFomValue:self.testItemNumber]];

    //12 Test Name
    [result addObject:[self getUploadCodingFieldFomValue:self.testName]];
    
    //13 Test Number
    [result addObject:[self getUploadCodingFieldFomValue:self.testNumber]];
    
    //14 Test Section Name
    [result addObject:[self getUploadCodingFieldFomValue:self.testSectionName]];

    //15 Test Section Number
    [result addObject:[self getUploadCodingFieldFomValue:self.testSectionNumber]];
    
    //16 Score
    [result addObject:[self getUploadCodingFieldFomValue:self.score]];

    //17 Company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];

    //18 Employee First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentFirstName]];
    
    //19 Employee Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentLastName]];
    
    //20 Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeId]];
    
    //21 Instructor first name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];
    
    //22 Instructor last name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];
    
    //23 Instructor Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorEmployeeId]];

    //24 Test Teaching String
    NSString *str = self.testTeachingString;
    if ([str containsString:@"\""]) {
        NSLog(@"");
    }
    
    //03.11.2019 some teaching strings had double quotes and teh call was failing
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    [result addObject:[self getUploadCodingFieldFomValue:str]];
    
    //25 Notes
    [result addObject:[self getUploadCodingFieldFomValue:self.notes]];

    //26 Location
    [result addObject:[self getUploadCodingFieldFomValue:self.location]];

    //27 Trailer number
    [result addObject:[self getUploadCodingFieldFomValue:self.trailerNumber]];

    //28 Odometer
    [result addObject:[self getUploadCodingFieldFomValue:self.odometer]];
    
    //29 leg
    [result addObject:[self getUploadCodingFieldFomValue:self.leg]];

    //30 leg
    [result addObject:[self getUploadCodingFieldFomValue:self.equipmentUsedMobileRecordId]];

    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
