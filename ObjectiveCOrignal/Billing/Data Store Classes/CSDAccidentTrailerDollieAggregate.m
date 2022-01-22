//
//  CSDAccidentTrailerDollieAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 5/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDAccidentTrailerDollieAggregate.h"
#import "AccidentTrailerDollie+CoreDataClass.h"
#import "DataRepository.h"

@implementation CSDAccidentTrailerDollieAggregate
- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"AccidentTrailerDollie";
        self.rcoObjectClass = @"AccidentTrailerDollie";
        self.rcoRecordType = @"Trailer or Dolly in Accident";
        self.aggregateRight = kTrainingAccident;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    AccidentTrailerDollie *op = (AccidentTrailerDollie *) object;
    
    if( [fieldName isEqualToString:@"DateTime"] ) {
        op.dateTime = [self rcoStringToDateTime:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Trailer Make"] ) {
        op.trailerMake = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Trailer Size"] ) {
        op.trailerSize = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Registration Current"] ) {
        op.registrationCurrent = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Inspection Current"] ) {
        op.inspectionCurrent = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"License Plate Number"] ) {
        op.licensePlateNumber = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"License State"] ) {
        op.licenseState = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Notes"] ) {
        op.notes = fieldValue;
        [op addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Dolly Type"] ) {
        op.dollyType = fieldValue;
        [op addSearchString:fieldValue];
    }
}

- (id) createNewRecord: (RCOObject *) obj {
    AccidentTrailerDollie *form = (AccidentTrailerDollie*)obj;
    
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
                                                  withMsg:DIA
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}
- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString: DIA]) {
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
    
    if ([msg isEqualToString: DIA]) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}

@end
