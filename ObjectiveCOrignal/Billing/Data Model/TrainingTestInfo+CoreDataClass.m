//
//  TrainingTestInfo+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 11/7/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingTestInfo+CoreDataClass.h"
#import "Settings.h"
#import "DataRepository.h"


@implementation TrainingTestInfo

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
    
    // 10 Student first name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentFirstName]];

    //11 Student Last name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentLastName]];

    //12 Student driver license number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];

    //13 Student driver license state
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];

    //14 Student driver license expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseExpirationDate]];

    //15 history reviewed
    [result addObject:[self getUploadCodingFieldFomValue:self.driverHistoryReviewed]];

    //16 driver license class
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseClass]];
    
    //17 company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];

    //18 endorsements
    [result addObject:[self getUploadCodingFieldFomValue:self.endorsements]];

    //19 DOT expiration date
    [result addObject:[self getUploadCodingFieldFomDateTime:self.dotExpirationDate]];
    
    // 20 instructor first name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];

    //21 instructor last name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];
    
    //22 instructor employy id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorEmployeeId]];

    //23 Parent mobile record id
    [result addObject:[self getUploadCodingFieldFomValue:self.parentMobileRecordId]];

    //24 Start date time
    [result addObject:[self getUploadCodingFieldFomDateTime:self.startDateTime]];

    //25 end datetime
    [result addObject:[self getUploadCodingFieldFomDateTime:self.endDateTime]];

    //26 evaluation location
    [result addObject:[self getUploadCodingFieldFomValue:self.evaluationLocation]];

    //27 power unit
    [result addObject:[self getUploadCodingFieldFomValue:self.powerUnit]];

    //28 corrective lens required
    [result addObject:[self getUploadCodingFieldFomValue:self.correctiveLensRequired]];

    //29 comments
    [result addObject:[self getUploadCodingFieldFomValue:self.comments]];

    //30 training pretrip
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingPreTrip]];

    //31 training behid the wheel
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingBehindTheWheel]];

    //32 training eye
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingEye]];

    //33 training SWP
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingSWP]];

    //34 training new hire
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingNewHire]];

    //35 training near miss
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingNearMiss]];

    //36 training incident follow up
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingIncidentFollowUp]];

    //37 training change job
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingChangeJob]];

    //38 training change of equipment
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingChangeOfEquipment]];

    //39 training annual
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingAnnual]];

    //40 training injury date
    [result addObject:[self getUploadCodingFieldFomDateTime:self.trainingInjuryDate]];

    //41 training accident date
    [result addObject:[self getUploadCodingFieldFomDateTime:self.trainingAccidentDate]];

    //42 training TAW end date
    [result addObject:[self getUploadCodingFieldFomDateTime:self.trainingTAWEndDate]];

    //43 training TAW start date
    [result addObject:[self getUploadCodingFieldFomDateTime:self.trainingTAWStartDate]];

    //44 training Lost Time Start
    [result addObject:[self getUploadCodingFieldFomDateTime:self.trainingLostTimeStartDate]];

    //45 training return to work
    [result addObject:[self getUploadCodingFieldFomDateTime:self.trainingReturnToWorkDate]];

    //46 stiudent employee id
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeId]];

    //47 restrictions
    [result addObject:[self getUploadCodingFieldFomValue:self.restrictions]];

    //48 Training Equipment
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingEquipment]];

    //49 Training Production
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingProd]];

    //50 Training Vehicle Road Test
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingVRT]];
    
    // 51 Elapsed Time
    [result addObject:[self getUploadCodingFieldFomValue:self.elapsedTime]];

    // 52 Points Received
    [result addObject:[self getUploadCodingFieldFomValue:self.pointsReceived]];

    // 53 Points Possible
    [result addObject:[self getUploadCodingFieldFomValue:self.pointsPossible]];

    // 54 Pause Date Times
    [result addObject:[self getUploadCodingFieldFomValue:self.pauseDateTimes]];

    // 55 Group Name
    [result addObject:[self getUploadCodingFieldFomValue:self.groupName]];

    // 56 Group Number
    [result addObject:[self getUploadCodingFieldFomValue:self.groupNumber]];

    // 57 Passanger Evacuation
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingPassengerEvacuation]];

    // 58 Passanger PreTrip
    [result addObject:[self getUploadCodingFieldFomValue:self.trainingPassengerPreTrip]];

    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

-(BOOL)isPaused {
    NSArray *items = [self.pauseDateTimes componentsSeparatedByString:@","];
    if (self.pauseDateTimes.length && (items.count%2)) {
        return YES;
    } else {
        return NO;
    }
}

-(void)addPauseDateTime:(NSDate*)dateTime {
    if (!dateTime) {
        return;
    }
    //22.01.2020 should we try to fix pause dates? for broken tests?
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


+(UIColor*)lightColor {
    return [UIColor colorWithRed:124.0/255 green:233.0/255 blue:245.0/255 alpha:1];
}

- (NSString *)displayableName {
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:[NSString stringWithFormat:@"Date&Time:\n%@", [self rcoDateTimeString:self.dateTime]]];
    [arr addObject:[NSString stringWithFormat:@"Started:\n%@", [self rcoDateTimeString:self.startDateTime]]];
    [arr addObject:[NSString stringWithFormat:@"Student:\n%@ %@", self.studentLastName, self.studentFirstName]];
    [arr addObject:[NSString stringWithFormat:@"Instructor:\n%@ %@", self.instructorLastName, self.instructorFirstName]];

    return [arr componentsJoinedByString:@"\n\n"];
}
@end
