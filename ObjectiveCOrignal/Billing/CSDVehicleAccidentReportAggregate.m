//
//  CSDVehicleAccidentReportAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 5/20/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDVehicleAccidentReportAggregate.h"
#import "AccidentVehicleReport+CoreDataClass.h"
#import "DataRepository.h"

@implementation CSDVehicleAccidentReportAggregate

- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"AccidentVehicleReport";
        self.rcoObjectClass = @"AccidentVehicleReport";
        self.rcoRecordType = @"Accident Vehicle Report";
        self.aggregateRight = kTrainingAccident;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)getUpdatedRecordsCount {
    
    [self resetSyncType];
    NSString *employeeId = [[DataRepository sharedInstance] getLoggedUserEmployeeId];;
    NSString *params = [NSString stringWithFormat:@"%@/-10000/%@/+/+/+/Employee Id/,/%@/,/+/+", self.rcoRecordType, [self getTimestampParameter], employeeId];
    
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F_C
                                         withParams: params
                                          andObject: nil
                                         callBackTo: self];
}

- (Boolean) requestSyncRecords {
    if (!self.countCallDone) {
        [self getUpdatedRecordsCount];
    } else {
        
        [self resetSyncType];
        [self setSyncType];
        NSString *employeeId = [[DataRepository sharedInstance] getLoggedUserEmployeeId];
        
        NSString *params = [NSString stringWithFormat:@"%@/-10000/%@/+/+/+/Employee Id/,/%@/,/+/+", self.rcoRecordType, [self getTimestampParameter], employeeId];
        [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                                withMsg: RD_G_R_U_X_F
                                             withParams: params
                                              andObject: nil
                                             callBackTo: self];
    }
    return YES;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    AccidentVehicleReport *op = (AccidentVehicleReport *) object;
    
    if( [fieldName isEqualToString:@"DateTime"] ) {
        op.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Are you injured"] ) {
        op.injured = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Degree of your injury"] || [fieldName isEqualToString:@"Degree of injuries"] ) {
        op.injuryDegreeYour = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Degree of accident"] ) {
        op.accidentDegree = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Is accident location secured"] ) {
        op.accidentLocationSecured = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Number of injuries"] ) {
        op.numberOfInjuries = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Anyone being transported"] ) {
        op.transported = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Any fatalities"] ) {
        op.fatilities = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Fire on site"] ) {
        op.fireonSite = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Police on site"] ) {
        op.policeOnSite = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Paramedics on site"] ) {
        op.paramedicsOnSite = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Coroner on site"] ) {
        op.coronerOnSite = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Is there fire"] ) {
        op.isFire = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Size of fire"] ) {
        op.sizeOfFire = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Fire extinguisher available"] ) {
        op.fireExtinguisherAvailable = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Fire extinguisher used"] ) {
        op.fireExtinguisherUsed = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Is there a spill"] ) {
        op.isThereASpill = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Size of spill"] ) {
        op.spillSize = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Type of spill"] ) {
        op.spillType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Is spill contained"] ) {
        op.spillContained = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Is another vehicle involved"] ) {
        op.anotherViehicleInvolved = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Number of vehicles involved"] ) {
        op.numberOfVehiclesInvolved = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Your vehicle need towing"] ) {
        op.vehicleNeedsTowing = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Other vehicles need towing"] ) {
        op.otherVehicleNeedsTowing = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Number of vehicles towed"] ) {
        op.numberOfVehiclesTowed = fieldValue;
    }
    else if( [fieldName isEqualToString:@"First Name"] ) {
        op.firstName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Last Name"] ) {
        op.lastName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Employee Id"] ) {
        op.employeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License Expiration Date"] ) {
        op.driverLicenseExpirationDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver License Number"] ) {
        op.driverLicenseNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License State"] ) {
        op.driverLicenseState = fieldValue;
    }
    else if( [fieldName isEqualToString:@"License Class"] ) {
        op.driverLicenseClass = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Home Phone Number"] ) {
        op.homePhone = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Work Phone Number"] ) {
        op.workPhone = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Mobile Phone Number"] ) {
        op.mobilePhone = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Description"] ) {
        op.accidentDescription = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Address"] ) {
        op.address1 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident City"] ) {
        op.city = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident State"] ) {
        op.state = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Zipcode"] ) {
        op.zip = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Location"] ) {
        op.location = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Weather Conditions"] ) {
        op.weatherConditions = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Site Description"] ) {
        op.accidentSiteDescription = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Latitude"] ) {
        op.latitude = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Longitude"] ) {
        op.longitude = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Chargeable Determination"] ) {
        op.accidentChargeableDetermination = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Crash Type"] ) {
        op.accidentCrashType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Incident Description"] ) {
        op.accidentIncidentDescription = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Incident Type"] ) {
        op.accidentIncidentType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Injury Occurred"] ) {
        op.accidentInjuryOccurred = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Severity Level"] ) {
        op.accidentSeverityLevel = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Root Cause Number One"] ) {
        op.rootCause1 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Prevention Activity Number One for Employee"] ) {
        op.preventionActivity1ForEmployee = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Prevention Activity Number One for Workforce"] ) {
        op.preventionActivity1ForWorkforce = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Root Cause Number Two"] ) {
        op.rootCause2 = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Prevention Activity Number Two for Employee"] ) {
        op.preventionActivity2ForEmployee = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Accident Prevention Activity Number Two for Workforce"] ) {
        op.preventionActivity2ForWorkforce = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Employee Accident History"] ) {
        op.employeeAccidentHistory = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Employment Date"] ) {
        op.employmentDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Annual Safety Review"] ) {
        op.annualSafetyReview = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Safety Review Date"] ) {
        op.safetyReviewDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Follow Up Training"] ) {
        op.followUpTraining = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Prior Training"] ) {
        op.priorTraining = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Employees Manager Workgroup Safety History"] ) {
        op.employeesManagerWorkgroupSafetyHistory = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Mentor Assigned"] ) {
        op.mentorAssigned = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Workforce Notification Posted"] ) {
        op.workforceNotificationPosted = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Transported to location"] ) {
        op.transportedToLocation = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Degree of other party injuries"] ) {
        op.injuryDegreeOthers = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Anyone else injured"] ) {
        op.anyoneElseInjured = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Was accident avoidable"] ) {
        op.wasAccidentAvoidable = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Who is at fault"] ) {
        op.whoIsTheFault = fieldValue;
    }
}

- (id) createNewRecord: (RCOObject *) obj {
    AccidentVehicleReport *form = (AccidentVehicleReport*)obj;
    
    if (!obj) {
        return nil;
    }
    
    NSString *formCSVFormat = [form CSVFormat];
    
    NSData *data = [formCSVFormat dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:A_S
                                                  withMsg:ACC
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}
- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString: ACC]) {
        NSString *rcoObjectId = [self parseSetRequest:request];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        if (rcoObjectId) {
            [result setObject:rcoObjectId forKey:@"objId"];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
        [self dispatchToTheListeners:kObjectUploadComplete withObjectId:rcoObjectId];
    } else {
        return [super requestFinished:request];
    }
}

- (void)requestFailed:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString: ACC]) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}

-(NSString*)fileNameForObject:(AccidentVehicleReport*)obj  {
    return [NSString stringWithFormat:@"Accident-%@ %@-%@", obj.lastName, obj.firstName, obj.employeeId];
}

@end
