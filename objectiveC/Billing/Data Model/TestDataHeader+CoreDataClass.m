//
//  TestDataHeader+CoreDataClass.m
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TestDataHeader+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation TestDataHeader
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
    
    //11 Employee First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentFirstName]];

    //12 Employee Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentLastName]];

    //13 Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeId]];

    //14 Instructor first name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];

    //15 Instructor last name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];

    //16 Instructor Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorEmployeeId]];

    // 17 class Var
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseClass]];

    //18 Endorsements
    [result addObject:[self getUploadCodingFieldFomValue:self.endorsements]];

    //19 Start Time
    [result addObject:[self getUploadCodingFieldFomDateTime:self.startDateTime]];
    
    //20 Finish Time
    [result addObject:[self getUploadCodingFieldFomDateTime:self.endDateTime]];
    
    // 21 dot expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.dotExpirationDate]];

    //22 Driver History Reviewed
    [result addObject:[self getUploadCodingFieldFomValue:self.driverHistoryReviewed]];

    //23 Driver License Number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];
    
    //24 Driver License State
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];

    //25 Power Unit
    [result addObject:[self getUploadCodingFieldFomValue:self.powerUnit]];

    //26 Corrective lens required
    [result addObject:[self getUploadCodingFieldFomValue:self.correctiveLensRequired]];

    //27 Location
    [result addObject:[self getUploadCodingFieldFomValue:self.location]];

    //28 DOT number
    [result addObject:[self getUploadCodingFieldFomValue:self.dotNumber]];

    //29 Points Possible
    [result addObject:[self getUploadCodingFieldFomValue:self.pointsPossible]];
    
    //30 Points Received
    [result addObject:[self getUploadCodingFieldFomValue:self.pointsReceived]];

    //31 Test Name
    [result addObject:[self getUploadCodingFieldFomValue:self.name]];
    
    //32 Test Number
    [result addObject:[self getUploadCodingFieldFomValue:self.number]];

    //33 Diver license expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseExpirationDate]];

    //34 Master Mobile RecordId
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoObjectParentId]];

    //35 Restrictions
    [result addObject:[self getUploadCodingFieldFomValue:self.restrictions]];

    //36 department
    [result addObject:[self getUploadCodingFieldFomValue:self.department]];

    //37 route number
    [result addObject:[self getUploadCodingFieldFomValue:self.routeNumber]];

    //38 onTime
    [result addObject:[self getUploadCodingFieldFomValue:self.onTime]];

    //39 keys ready
    [result addObject:[self getUploadCodingFieldFomValue:self.keysReady]];

    //40 timecard system ready
    [result addObject:[self getUploadCodingFieldFomValue:self.timecardSystemReady]];

    //41 equipment ready
    [result addObject:[self getUploadCodingFieldFomValue:self.equipmentReady]];

    //42 equipment clean
    [result addObject:[self getUploadCodingFieldFomValue:self.equipmentClean]];

    //43 start odometer
    [result addObject:[self getUploadCodingFieldFomValue:self.startOdometer]];

    //44 finish odometer
    [result addObject:[self getUploadCodingFieldFomValue:self.finishOdometer]];

    //45 miles
    [result addObject:[self getUploadCodingFieldFomValue:self.miles]];

    //46 elapsedTime
    [result addObject:[self getUploadCodingFieldFomValue:self.elapsedTime]];

    //47 pause dateTimes
    [result addObject:[self getUploadCodingFieldFomValue:self.pauseDateTimes]];

    //48 Test Result
    [result addObject:[self getUploadCodingFieldFomValue:self.testResult]];

    //49 Test Remarks
    [result addObject:[self getUploadCodingFieldFomValue:self.testRemarks]];

    //50 Test Qualified yes or no
    [result addObject:[self getUploadCodingFieldFomValue:self.qualifiedYesNo]];

    //51 Disqualified Remarks
    [result addObject:[self getUploadCodingFieldFomValue:self.disqualifiedRemarks]];

    //52 testDate
    [result addObject:[self getUploadCodingFieldFomValue:self.testDate]];

    //53 testMiles
    [result addObject:[self getUploadCodingFieldFomValue:self.testMiles]];

    //54 medicalCardExpirationDate
    [result addObject:[self getUploadCodingFieldFomValue:self.medicalCardExpirationDate]];

    //55 testState
    [result addObject:[self getUploadCodingFieldFomValue:self.testState]];

    //56 trailerLength
    [result addObject:[self getUploadCodingFieldFomValue:self.trailerLength]];

    //57 numberofTrailers
    [result addObject:[self getUploadCodingFieldFomValue:self.numberofTrailers]];

    //58 evaluatorName
    [result addObject:[self getUploadCodingFieldFomValue:self.evaluatorName]];

    //59 evaluatorTitle
    [result addObject:[self getUploadCodingFieldFomValue:self.evaluatorTitle]];

    //60 Observator first name
    [result addObject:[self getUploadCodingFieldFomValue:self.observerFirstName]];

    //61 observator last name
    [result addObject:[self getUploadCodingFieldFomValue:self.observerLastName]];
    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

-(NSString*)employee {
    NSMutableArray *comp = [NSMutableArray array];
    if (self.studentLastName.length) {
        [comp addObject:self.studentLastName];
    }
    if (self.studentFirstName.length) {
        [comp addObject:self.studentFirstName];
    }
    return [comp componentsJoinedByString:@" "];
}

-(NSString*)driverName {
    return [self employee];
}

-(NSString*)pointsPercentage {
    double percentage = 0.0;
    if (self.pointsPossible.integerValue) {
        percentage = [self.pointsReceived doubleValue]*1.0/self.pointsPossible.doubleValue;
    }
    return [NSString stringWithFormat:@"%0.2f%%", percentage*100];
}

-(BOOL)isPaused {
    NSArray *items = [self.pauseDateTimes componentsSeparatedByString:@","];
    if (self.pauseDateTimes.length && (items.count%2)) {
        return YES;
    } else {
        return NO;
    }
}
-(NSDate*)getPauseDate {
    if (![self isPaused]) {
        return nil;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss"];

    NSArray *pausedDateTimes = [self.pauseDateTimes componentsSeparatedByString:@","];
    NSString *str = [pausedDateTimes lastObject];
    
    NSDate *date = [dateFormat dateFromString:str];
    return date;
}

-(void)addPauseDateTime:(NSDate*)dateTime {
    if (!dateTime) {
        return;
    }
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self.pauseDateTimes componentsSeparatedByString:@","]];
    
    [items removeObjectsInArray:@[@""]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSString *date_str = [dateFormat stringFromDate:dateTime];
    
    [items addObject:date_str];
    self.pauseDateTimes = [items componentsJoinedByString:@","];
}

-(NSString*)calculateElaspsedTime {
    if (!self.startDateTime) {
        return @"0";
    }
    
    if (!self.pauseDateTimes.length && !self.endDateTime) {
        return @"0";
    }
    
    NSMutableArray *dates = [NSMutableArray array];
    [dates addObject:self.startDateTime];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss"];

    if (self.pauseDateTimes.length) {
        NSArray *pausedDateTimes = [self.pauseDateTimes componentsSeparatedByString:@","];
        for (NSString *str in pausedDateTimes) {
            NSDate *date = [dateFormat dateFromString:str];
            if (date) {
                [dates addObject:date];
            }
        }
    }
    
    if (self.endDateTime) {
        [dates addObject:self.endDateTime];
    }
    double duration = 0;
    for (NSInteger i = 0; ;) {
        NSDate *date1 = nil;
        NSDate *date2 = nil;
        if (i < dates.count) {
            date1 = [dates objectAtIndex:i];
        } else {
            break;
        }
        if ((i+1) < dates.count) {
            date2 = [dates objectAtIndex:(i+1)];
        } else {
            break;
        }
        double delta = [date2 timeIntervalSince1970] - [date1 timeIntervalSince1970];
        if (delta < 0) {
            NSLog(@"");
        }
        duration += delta;
        i += 2;
    }
    int minutes = duration / 60;
    
    return [NSString stringWithFormat:@"%d", minutes];
}

-(NSString*)evaluationLocation {
    return @"location";
}

+(NSString*)encodeText:(NSString*)text {
    return [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
}

+(NSString*)decodeText:(NSString*)text {
    return [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
}

@end
