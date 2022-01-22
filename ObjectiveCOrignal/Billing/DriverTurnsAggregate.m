//
//  DriverTurnsAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 3/25/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "DriverTurnsAggregate.h"
#import "RCOObject+RCOObject_Imp.h"
#import "DriverTurn+CoreDataClass.h"
#import "DataRepository.h"

@implementation DriverTurnsAggregate
- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"DriverTurn";
        self.rcoObjectClass = @"DriverTurn";
        self.rcoRecordType = @"Driving Turn";
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
        skipSyncRecords = YES;

    }
    return self;
}

- (Boolean) requestSync {
    NSString *timestamp = @"99999999999999";
    
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: [NSString stringWithFormat:@"%@/10000/%@/HeaderBarcode/%@", self.rcoRecordType, timestamp, @"1"]
                                          andObject: nil
                                         callBackTo: self];
    
    return YES;
}

- (void)getTurnsForHeaderWithMobileRecordId:(NSString*)mobileRecordId {
    NSString *params = [NSString stringWithFormat:@"%@/-10000/%lld/+/+/+/MasterMobileRecordId/,/%@/,/+/+", self.rcoRecordType, [self.synchingTimeStamp longLongValue], mobileRecordId];
        
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: mobileRecordId
                                         callBackTo: self];
}


-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    DriverTurn *op = (DriverTurn *) object;
    
    if( [fieldName isEqualToString:@"Driving Turn Type"] )
    {
        op.turnType = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Latitude"] )
    {
        op.latitude = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Longitude"] )
    {
        op.longitude = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Company"] )
    {
        op.company = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Student First Name"] )
    {
        op.studentFirstName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Student Last Name"] )
    {
        op.studentLastName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Employee Id"] )
    {
        op.employeeId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor First Name"] )
    {
        op.instructorFirstName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor Last Name"] )
    {
        op.instructorLastName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Instructor Id"] )
    {
        op.instructorId = fieldValue;
    }
    else if( [fieldName isEqualToString:@"DateTime"] )
    {
        op.dateTime = [self rcoStringToDateTime:fieldValue];;
    }
    else if( [fieldName isEqualToString:@"MasterMobileRecordId"] )
    {
        op.masterMobileRecordId = fieldValue;
    }
}

-(NSArray*)getTurnsForTest:(NSString*)testInfoMobileRecordId {
    if (!testInfoMobileRecordId.length) {
        return nil;
    }
    
    NSArray *res = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterMobileRecordId=%@", testInfoMobileRecordId];
    res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    return res;
}

-(BOOL)resetLocalFields {
    return YES;
}

- (id) createNewRecord: (RCOObject *) obj {
    DriverTurn *form = (DriverTurn*)obj;
    
    if (!obj) {
        return nil;
    }
    
    NSString *formCSVFormat = [form CSVFormat];
        
    NSData *data = [formCSVFormat dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:T_S
                                                  withMsg:TURNS
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}

- (void)requestFinished_Bkgd:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    NSString *objId = [msgDict objectForKey:@"objId"];
    if ([msg isEqualToString: RD_G_R_U_X_F]&& objId.length) {
        [super requestFinished_Bkgd:request];
        NSMutableDictionary *respDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:respDict withArg2:nil];
    } else {
        return [super requestFinished_Bkgd:request];
    }
}
- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    NSString *objId = [msgDict objectForKey:@"objId"];
    if ([msg isEqualToString: TURNS]) {
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
    
    if ([msg isEqualToString: TURNS]) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}


@end
