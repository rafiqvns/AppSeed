//
//  TrainingEquipmentReviewedAggregate.m
//  CSD
//
//  Created by .D. .D. on 11/5/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TrainingEquipmentReviewedAggregate.h"
#import "TrainingEquipmentReviewed+CoreDataClass.h"
#import "DataRepository.h"
#import "Settings.h"

@implementation TrainingEquipmentReviewedAggregate
- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"TrainingEquipmentReviewed";
        self.rcoObjectClass = @"TrainingEquipmentReviewed";
        self.rcoRecordType = @"Equipment Reviewed";
        self.aggregateRight = kTrainingRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TrainingEquipmentReviewed *te = (TrainingEquipmentReviewed *) object;

    if( [fieldName isEqualToString:@"Student First Name"] )
    {
        te.studentFirstName = fieldValue;
        [te addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Student Last Name"] )
    {
        te.studentLastName = fieldValue;
        [te addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Employee Id"] )
    {
        te.employeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License Number"] )
    {
        te.studentDriverLicenseNumber = fieldValue;
        [te addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver License State"] )
    {
        te.studentDriverLicenseState = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License State"] )
    {
        te.studentDriverLicenseState = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor First Name"] )
    {
        te.instructorFirstName = fieldValue;
        [te addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Instructor Last Name"] )
    {
        te.instructorLastName = fieldValue;
        [te addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Instructor Employee Id"] )
    {
        te.instructorEmployeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"MasterMobileRecordId"] )
    {
        te.parentMobileRecordId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Company"] )
    {
        te.company = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Equipment Type"] )
    {
        te.equipmentType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Notes"] )
    {
        te.notes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type"] )
    {
        te.vehicleType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Type Notes"] )
    {
        te.vehicleTypeNotes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Manufacturer"] )
    {
        te.vehicleManufacturer = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Vehicle Mfg Notes"] )
    {
        te.vehicleManufacturerNotes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Single Trailer Length"] )
    {
        te.singleTrailerLength = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Single Trailer Notes"] )
    {
        te.singleTrailerNotes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"LVC Type"] )
    {
        te.lVCType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"LVC Type Notes"] )
    {
        te.lVCTypeNotes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"LVC Length"] )
    {
        te.lVCLength = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Dolly Gear Type"] )
    {
        te.dollyGearType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Dolly Gear Notes"] )
    {
        te.dollyGearTypeNotes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DateTime"] )
    {
        te.dateTime = [self rcoStringToDateTime:fieldValue];
    }
}

- (id) createNewRecord: (RCOObject *) obj {
    TrainingEquipmentReviewed *form = (TrainingEquipmentReviewed*)obj;
    
    if (!obj) {
        return nil;
    }
        
    NSString *dataPlain = [form CSVFormat];
    
    NSLog(@" Equipment Reviewed format = %@", dataPlain);
    NSData *data = [dataPlain dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:T_S
                                                  withMsg:SET_EQUIPMENT_REVIEWED
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}

- (void)requestFinished:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if([msg isEqualToString: SET_EQUIPMENT_REVIEWED]) {
        NSString *rcoObjectId = [self parseSetRequest:request];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
                
        if (rcoObjectId) {
            [result setObject:rcoObjectId forKey:@"objId"];
        }
        
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
        [self dispatchToTheListeners:kObjectUploadComplete withObjectId:rcoObjectId];
        NSLog(@"res = %@", result);
    } else {
        return [super requestFinished:request];
    }
}

- (void)requestFailed:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if([msg isEqualToString: SET_EQUIPMENT_REVIEWED]) {
        NSLog(@"");
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}

-(NSArray*)getTrainingEquipmentForDrivingLicenseNumber:(NSString*)number driverLicenseState:(NSString*)state andInstructor:(NSString*)instructorEmployeeId {
    
    if (!number.length || !state.length) {
        return nil;
    }
    NSMutableArray *predicates = [NSMutableArray array];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"studentDriverLicenseNumber=%@", number];
    [predicates addObject:p];
    p = [NSPredicate predicateWithFormat:@"studentDriverLicenseState=%@", state];
    [predicates addObject:p];
    if (instructorEmployeeId.length) {
        p = [NSPredicate predicateWithFormat:@"instructorEmployeeId=%@", instructorEmployeeId];
        [predicates addObject:p];
    }
    p = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    NSArray *res = [self getAllNarrowedBy:p andSortedBy:nil];
    return res;
}

-(NSArray*)getEquipmentReviewedForTestInfo:(NSString*)testInfoMobileRecordId {
    if (!testInfoMobileRecordId.length) {
        return nil;
    }
    NSPredicate *p = [NSPredicate predicateWithFormat:@"parentMobileRecordId=%@", testInfoMobileRecordId];
    NSArray *res = [self getAllNarrowedBy:p andSortedBy:nil];
    return res;
}

-(BOOL)FFFilter {
    
    return NO;
    
    // 24.10.2019 do we still need a super user?
    return YES;
    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    if (![[organizationName lowercaseString] isEqualToString:[userCompany lowercaseString]]) {
        return YES;
    }
    return NO;
}

- (NSString*)filterCodingFielValue {
    NSString *employeeId = [Settings getSetting:CLIENT_USER_EMPLOYEEID_KEY];
    return employeeId;
}

- (NSString*)filterCodingFieldName {
    return @"Instructor Employee Id";
}

@end
