//
//  TrainingTestInfoAggregate.m
//  CSD
//
//  Created by .D. .D. on 11/7/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TrainingTestInfoAggregate.h"
#import "TrainingTestInfo+CoreDataClass.h"
#import "DataRepository.h"
#import "Settings.h"

@implementation TrainingTestInfoAggregate
- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"TrainingTestInfo";
        self.rcoObjectClass = @"TrainingTestInfo";
        self.rcoRecordType = @"Training Test Info";
        self.aggregateRight = kTrainingRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
        
        self.linkedRecords = [[NSArray alloc] initWithObjects:@"Attachment", @"Training Break Location", nil];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TrainingTestInfo *tti = (TrainingTestInfo *) object;

    if( [fieldName isEqualToString:@"Student First Name"] )
    {
        tti.studentFirstName = fieldValue;
        [tti addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Student Last Name"] )
    {
        tti.studentLastName = fieldValue;
        [tti addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"DateTime"] ) {
        tti.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver License Number"] )
    {
        tti.driverLicenseNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License State"] )
    {
        tti.driverLicenseState = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License State"] )
    {
        tti.driverLicenseState = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License Expiration Date"] ) {
        tti.driverLicenseExpirationDate = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver History Reviewed"] )
    {
        tti.driverHistoryReviewed = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License Class"] )
    {
        tti.driverLicenseClass = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Company"] )
    {
        tti.company = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Endorsements"] )
    {
        tti.endorsements = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DOT Expiration Date"] ) {
        tti.dotExpirationDate = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Instructor First Name"] )
    {
        tti.instructorFirstName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor Last Name"] )
    {
        tti.instructorLastName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor Employee Id"] )
    {
        tti.instructorEmployeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"StartDateTime"] )
    {
        tti.startDateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"EndDateTime"] )
    {
        tti.endDateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Evaluation Location"] )
    {
        tti.evaluationLocation = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Power Unit"] )
    {
        tti.powerUnit = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Corrective Lens Required"] )
    {
        tti.correctiveLensRequired = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Comments"] )
    {
        tti.comments = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training PreTrip"] )
    {
        tti.trainingPreTrip = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Behind the Wheel"] )
    {
        tti.trainingBehindTheWheel = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Eye Movement"] )
    {
        tti.trainingEye = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Safe Work Practice"] )
    {
        tti.trainingSWP = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training New Hire"] )
    {
        tti.trainingNewHire = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Near Miss"] )
    {
        tti.trainingNearMiss = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Incident Follow-up"] )
    {
        tti.trainingIncidentFollowUp = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Change Job"] )
    {
        tti.trainingChangeJob = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Change of Equipment"] )
    {
        tti.trainingChangeOfEquipment = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Annual"] )
    {
        tti.trainingAnnual = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Injury Date"] )
    {
        tti.trainingInjuryDate = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Training Accident Date"] )
    {
        tti.trainingAccidentDate = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Training TAW End Date"] )
    {
        tti.trainingTAWEndDate = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Training TAW Start Date"] )
    {
        tti.trainingTAWStartDate = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Training Lost Time Start Date"] )
    {
        tti.trainingLostTimeStartDate = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Training Return to Work Date"] )
    {
        tti.trainingReturnToWorkDate = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Student Employee Id"] )
    {
        tti.employeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Restrictions"] )
    {
        tti.restrictions = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Equipment"] )
    {
        tti.trainingEquipment = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Production"] )
    {
        tti.trainingProd = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Training Vehicle Road Test"] )
    {
        tti.trainingVRT = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Elapsed Time"] )
    {
        tti.elapsedTime = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Points Received"] )
    {
        tti.pointsReceived = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Points Possible"] )
    {
        tti.pointsPossible = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Pause DateTimes"] )
    {
        tti.pauseDateTimes = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Group Name"] )
    {
        tti.groupName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Group Number"] )
    {
        tti.groupNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Passenger Evacuation"] )
    {
        tti.trainingPassengerEvacuation = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Passenger PreTrip"] )
    {
        tti.trainingPassengerPreTrip = fieldValue;
    }
}

-(NSArray*)getTestsForDriverLicenseNumbed:(NSString*)driverLicenseNumber andDriverLicenseState:(NSString*)driverLicenseState {
    if (!driverLicenseNumber.length || !driverLicenseState.length) {
        return nil;
    }
    NSPredicate *p = [NSPredicate predicateWithFormat:@"driverLicenseNumber=%@ and driverLicenseState=%@", driverLicenseNumber, driverLicenseState];
    NSArray *res = [self getAllNarrowedBy:p andSortedBy:nil];
    return res;
}

-(TrainingTestInfo*)getMostRecentTestForDriverLicenseNumber:(NSString*)driverLicenseNumber andDriverLicenseState:(NSString*)driverLicenseState {
    if (!driverLicenseNumber.length || !driverLicenseState.length) {
        return nil;
    }
    NSPredicate *p = [NSPredicate predicateWithFormat:@"driverLicenseNumber=%@ and driverLicenseState=%@", driverLicenseNumber, driverLicenseState];
    NSArray *res = [self getAllNarrowedBy:p andSortedBy:nil];
    
    // 30.01.2020 added predicate to get not ended tests
    NSPredicate *notEndedPredicate = [NSPredicate predicateWithFormat:@"endDateTime=%@", nil];
    res = [res filteredArrayUsingPredicate:notEndedPredicate];
    
    if (res.count) {
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"dateTime" ascending:YES];
        return [[res sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]] lastObject];
    }
    
    return nil;
}

- (id) createNewRecord: (RCOObject *) obj {
    TrainingTestInfo *form = (TrainingTestInfo*)obj;
    
    if (!obj) {
        return nil;
    }
        
    NSString *dataPlain = [form CSVFormat];
    NSData *data = [dataPlain dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:T_S
                                                  withMsg:CLAS
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}

- (void)requestFinished:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if([msg isEqualToString: CLAS]) {
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
    
    if([msg isEqualToString: CLAS]) {
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

-(BOOL)FFFilter {
    
    return NO;
    
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
    // 17.01.2020
    return [NSString stringWithFormat:@"%@,%@", employeeId, @"no"];
    return employeeId;
}

- (NSString*)filterCodingFieldName {
    return @"Instructor Employee Id,Is Complete";
    return @"Instructor Employee Id";
}
@end
