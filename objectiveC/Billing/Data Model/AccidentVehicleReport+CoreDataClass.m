//
//  AccidentVehicleReport+CoreDataClass.m
//  MobileOffice
//
//  Created by .D. .D. on 5/21/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "AccidentVehicleReport+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"
#import "Aggregate.h"


@implementation AccidentVehicleReport

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
    
    //10 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.injured]];

    //11 Degree of injury
    [result addObject:[self getUploadCodingFieldFomValue:self.injuryDegreeYour]];

    //12 Degree of accident
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentDegree]];

    //13 Is accident location secured
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentLocationSecured]];
    
    // 14 number of injuries
    [result addObject:[self getUploadCodingFieldFomValue:self.numberOfInjuries]];
    
    // 15 degrees of injuries
    [result addObject:[self getUploadCodingFieldFomValue:self.injuryDegreeOthers]];
    
    // 16 anyone being transported
    [result addObject:[self getUploadCodingFieldFomValue:self.transported]];
    
    // 17 fatilities
    [result addObject:[self getUploadCodingFieldFomValue:self.fatilities]];

    // 18 fire on site
    [result addObject:[self getUploadCodingFieldFomValue:self.fireonSite]];
    
    // 19 police on site
    [result addObject:[self getUploadCodingFieldFomValue:self.policeOnSite]];

    // 20 paramedics on site
    [result addObject:[self getUploadCodingFieldFomValue:self.paramedicsOnSite]];
    
    // 21 coroner on site
    [result addObject:[self getUploadCodingFieldFomValue:self.coronerOnSite]];
    
    // 22 is there fire
    [result addObject:[self getUploadCodingFieldFomValue:self.isFire]];
    
    // 23 size of fire
    [result addObject:[self getUploadCodingFieldFomValue:self.sizeOfFire]];
    
    // 24 fire extinguisher available
    [result addObject:[self getUploadCodingFieldFomValue:self.fireExtinguisherAvailable]];
    
    // 25 fire extinguisher user
    [result addObject:[self getUploadCodingFieldFomValue:self.fireExtinguisherUsed]];
    
    // 26 is there a spil
    [result addObject:[self getUploadCodingFieldFomValue:self.isThereASpill]];
    
    // 27 size of spil
    [result addObject:[self getUploadCodingFieldFomValue:self.spillSize]];
    
    // 28 type of spil
    [result addObject:[self getUploadCodingFieldFomValue:self.spillType]];
    
    // 29 is spil contained
    [result addObject:[self getUploadCodingFieldFomValue:self.spillContained]];
    
    // 30 is another vehicle involved
    [result addObject:[self getUploadCodingFieldFomValue:self.anotherViehicleInvolved]];
    
    // 31 number of vehicles involved
    [result addObject:[self getUploadCodingFieldFomValue:self.numberOfVehiclesInvolved]];
    
    // 32 your vehicle need towing
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleNeedsTowing]];
    
    // 33 other vehicles need towing
    [result addObject:[self getUploadCodingFieldFomValue:self.otherVehicleNeedsTowing]];
    
    // 34 number of vehicles towed
    [result addObject:[self getUploadCodingFieldFomValue:self.numberOfVehiclesTowed]];
    
    // 35 first name
    [result addObject:[self getUploadCodingFieldFomValue:self.firstName]];
    
    // 36 last name
    [result addObject:[self getUploadCodingFieldFomValue:self.lastName]];

    // 37 employee id
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeId]];
    
    // 38 driver license expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseExpirationDate]];
    
    // 39 driver license number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];
    
    //40 driver license state
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];
    
    // 41 license class
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseClass]];
    
    // 42 home phone number
    [result addObject:[self getUploadCodingFieldFomValue:self.homePhone]];
    
    // 43 work phone number
    [result addObject:[self getUploadCodingFieldFomValue:self.workPhone]];
    
    // 44 mobile phone number
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilePhone]];
    
    // 45 accident description
    [result addObject:[self getUploadCodingFieldFomValue:self.objectDescription]];
    
    // 46 accident address
    [result addObject:[self getUploadCodingFieldFomValue:self.address1]];

    // 47 accident city
    [result addObject:[self getUploadCodingFieldFomValue:self.city]];
    
    // 48 accident state
    [result addObject:[self getUploadCodingFieldFomValue:self.state]];
    
    // 49 accident zipcode
    [result addObject:[self getUploadCodingFieldFomValue:self.zip]];
    
    // 50 accident location
    [result addObject:[self getUploadCodingFieldFomValue:self.location]];
    
    // 51 accident wather conditions
    [result addObject:[self getUploadCodingFieldFomValue:self.weatherConditions]];
    
    // 52 accident site description
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentSiteDescription]];
    
    // 53 latitude TODO
    [result addObject:[self getUploadCodingFieldFomValue:self.latitude]];

    // 54 longitude TODO
    [result addObject:[self getUploadCodingFieldFomValue:self.longitude]];

    // 55 accident Chargeable Determination
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentChargeableDetermination]];

    // 56 crash type
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentCrashType]];

    // 57 accidentIncidentDescription
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentIncidentDescription]];

    // 58 accidentIncidentType
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentIncidentType]];

    // 59 accidentInjuryOccurred
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentInjuryOccurred]];

    // 60 accidentSeverityLevel
    [result addObject:[self getUploadCodingFieldFomValue:self.accidentSeverityLevel]];

    // 61 accidentRootCauseNumberOne
    [result addObject:[self getUploadCodingFieldFomValue:self.rootCause1]];

    // 62 accidentPreventionActivityNumberOneforEmployee
    [result addObject:[self getUploadCodingFieldFomValue:self.preventionActivity1ForEmployee]];

    // 63 accidentPreventionActivityNumberOneforWorkforce
    [result addObject:[self getUploadCodingFieldFomValue:self.preventionActivity1ForWorkforce]];

    // 64 accidentRootCauseNumberTwo
    [result addObject:[self getUploadCodingFieldFomValue:self.rootCause2]];

    // 65 accidentPreventionActivityNumberTwoforEmployee
    [result addObject:[self getUploadCodingFieldFomValue:self.preventionActivity2ForEmployee]];

    // 66 accidentPreventionActivityNumberTwoforWorkforce
    [result addObject:[self getUploadCodingFieldFomValue:self.preventionActivity2ForWorkforce]];

    // 67 employeeAccidentHistory
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeAccidentHistory]];

    // 68 employmentDate
    [result addObject:[self getUploadCodingFieldFomValue:self.employmentDate]];

    // 69 annualSafetyReview
    [result addObject:[self getUploadCodingFieldFomValue:self.annualSafetyReview]];

    // 70 safetyReviewDate
    [result addObject:[self getUploadCodingFieldFomValue:self.safetyReviewDate]];

    // 71 followUpTraining
    [result addObject:[self getUploadCodingFieldFomValue:self.followUpTraining]];

    // 72 priorTraining
    [result addObject:[self getUploadCodingFieldFomValue:self.priorTraining]];

    // 73 employeesManagerWorkgroupSafetyHistory
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeAccidentHistory]];

    // 74 mentorAssigned
    [result addObject:[self getUploadCodingFieldFomValue:self.mentorAssigned]];

    // 75 workforceNotificationPosted
    [result addObject:[self getUploadCodingFieldFomValue:self.workforceNotificationPosted]];

    // 76 transported to location
    [result addObject:[self getUploadCodingFieldFomValue:self.transportedToLocation]];

    // 77 Degree of the party injury
    [result addObject:[self getUploadCodingFieldFomValue:self.injuryDegreeOthers]];

    // 78 anyone else injured
    [result addObject:[self getUploadCodingFieldFomValue:self.anyoneElseInjured]];

    // 79 was accident avidable
    [result addObject:[self getUploadCodingFieldFomValue:self.wasAccidentAvoidable]];

    // 80 anyone else injured
    [result addObject:[self getUploadCodingFieldFomValue:self.whoIsTheFault]];

    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
