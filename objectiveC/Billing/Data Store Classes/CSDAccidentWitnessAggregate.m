//
//  CSDAccidentWitnessAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 5/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDAccidentWitnessAggregate.h"
#import "AccidentWitness+CoreDataClass.h"
#import "DataRepository.h"

@implementation CSDAccidentWitnessAggregate
- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"AccidentWitness";
        self.rcoObjectClass = @"AccidentWitness";
        self.rcoRecordType = @"Witness to Accident";
        self.aggregateRight = kTrainingAccident;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    AccidentWitness *op = (AccidentWitness *) object;
    
    if( [fieldName isEqualToString:@"DateTime"] ) {
        op.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"First Name"] ) {
        op.firstName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Last Name"] ) {
        op.lastName = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Driver License Number"] ) {
        op.driverLicenseNumber = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Home Phone Number"] ) {
        op.homePhone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Work Phone Number"] ) {
        op.workPhone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Mobile Phone Number"] ) {
        op.mobilePhone = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Notes"] ) {
        op.notes = fieldValue;
        [op addSearchString:fieldValue];
    }
}

- (id) createNewRecord: (RCOObject *) obj {
    AccidentWitness *form = (AccidentWitness*)obj;
    
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
                                                  withMsg:WIT
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}
- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString: WIT]) {
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
    
    if ([msg isEqualToString: WIT]) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}

@end
