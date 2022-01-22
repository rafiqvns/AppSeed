//
//  TrainingScoreAggregate.m
//  CSD
//
//  Created by .D. .D. on 12/27/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "TrainingScoreAggregate.h"
#import "TrainingScore+CoreDataClass.h"
#import "DataRepository.h"


@implementation TrainingScoreAggregate
- (id) init {
    if ((self = [super init]) != nil){
    
        self.localObjectClass = @"TrainingScore";
        self.rcoObjectClass = @"TrainingScore";
        self.rcoRecordType = @"Training Score";
        self.aggregateRight = kTrainingRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (Boolean) requestSync {
    NSString *timestamp = @"99999999999999";
    
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: [NSString stringWithFormat:@"%@/10000/%@/HeaderBarcode/%@", self.rcoRecordType, timestamp, @"1"]
                                          andObject: nil
                                         callBackTo:self];

    return YES;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TrainingScore *tc = (TrainingScore *) object;

    if( [fieldName isEqualToString:@"Student First Name"] )
    {
        tc.studentFirstName = fieldValue;
        [tc addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Student Last Name"] )
    {
        tc.studentLastName = fieldValue;
        [tc addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"DateTime"] ) {
        tc.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver License Number"] )
    {
        tc.driverLicenseNumber = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Driver License State"] )
    {
        tc.driverLicenseState = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Company"] )
    {
        tc.company = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Employee Id"] )
    {
        tc.employeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor First Name"] )
    {
        tc.instructorFirstName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor Last Name"] )
    {
        tc.instructorLastName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor Employee Id"] )
    {
        tc.instructorEmployeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Test Name"] )
    {
        tc.testName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Section Name"] )
    {
        tc.sectionName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Elapsed Time"] )
    {
        tc.elapsedTime = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Points Received"] )
    {
        tc.pointsReceived = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Points Possible"] )
    {
        tc.pointsPossible = fieldValue;
    }
    else if( [fieldName isEqualToString:@"MasterMobileRecordId"] )
    {
        tc.masterMobileRecordId = fieldValue;
    }
}

- (id) createNewRecord: (RCOObject *) obj {
    TrainingScore *ts = (TrainingScore*)obj;
    
    if (!obj) {
        return nil;
    }
        
    NSString *dataPlain = [ts CSVFormat];
    NSData *data = [dataPlain dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:T_S
                                                  withMsg:ST
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}

-(void)getScoresForStudent:(NSString*)studentId fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate {
    if (!studentId.length) {
        studentId = @"+";
    }
    if (!fromDate || !toDate) {
        return;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];

    NSString *params = [NSString stringWithFormat:@"%@/%@/%@",studentId, [dateFormat stringFromDate:fromDate], [dateFormat stringFromDate:toDate]];

    [[DataRepository sharedInstance] askTheCloudFor: T_S
                                            withMsg: STG
                                         withParams: params
                                          andObject: nil
                                         callBackTo: self];
}

- (void)requestFinished:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if([msg isEqualToString: STG]) {
        NSLog(@"");
        NSMutableDictionary *respDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];

        id respObject = [request objectForKey:RESPONSE_OBJ];
        if (respObject) {
            [respDict setObject:respObject forKey:RESPONSE_OBJ];
        }

        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:respDict withArg2:nil];

    } else if([msg isEqualToString: ST]) {
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
    
    if([msg isEqualToString: STG]) {
    } else if([msg isEqualToString: ST]) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}

@end
