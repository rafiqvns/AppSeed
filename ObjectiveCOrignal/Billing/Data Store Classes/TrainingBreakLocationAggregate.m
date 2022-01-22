//
//  TrainingBreakLocationAggregate.m
//  CSD
//
//  Created by .D. .D. on 4/2/20.
//  Copyright © 2020 RCO. All rights reserved.
//

#import "TrainingBreakLocationAggregate.h"
#import "TrainingBreakLocation+CoreDataClass.h"
#import "DataRepository.h"

@implementation TrainingBreakLocationAggregate

- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"TrainingBreakLocation";
        self.rcoObjectClass = @"TrainingBreakLocation";
        self.rcoRecordType = @"Training Break Location";
        self.aggregateRight = kTrainingRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
        skipSyncRecords = YES;
    }
    return self;
}

- (id ) createNewRecord: (RCOObject *) obj {
    TrainingBreakLocation *ev = (TrainingBreakLocation *) obj;
    
    if (!ev) {
        return nil;
    }

    [self addSync];
    
    NSString *evInfo = [ev CSVFormat];

    NSData *data = [evInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    if ([ev.headerObjectId integerValue] == 0) {
        if (ev.headerObjectType) {
            Aggregate *parentAgg = [[DataRepository sharedInstance] getAggregateForClass:ev.headerObjectType];
            
            NSArray *allEvents = [parentAgg getAll];
            
            RCOObject *obj = [parentAgg getObjectMobileRecordId:ev.headerObjectId];
            
            if ([obj existsOnServerNew]) {
                ev.headerObjectId = obj.rcoObjectId;
                ev.headerObjectType = obj.rcoObjectType;
                ev.headerBarcode = obj.rcoBarcode;
                [self save];
                evInfo = [ev CSVFormat];
                data = [evInfo dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                return nil;
            }
        }
    }

    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];

    return  [[DataRepository sharedInstance] tellTheCloud:T_S
                                                  withMsg:TL
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}


-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    TrainingBreakLocation *tbl = (TrainingBreakLocation *) object;

    if ([fieldName isEqualToString:@"Title"]) {
        tbl.title = fieldValue;
        [tbl addSearchString:fieldValue];
    } else if ([fieldName isEqualToString:@"Notes"]) {
        tbl.notes = fieldValue;
        [tbl addSearchString:fieldValue];
    } else if ([fieldName isEqualToString:@"Location"]) {
        tbl.location = fieldValue;
    } else if ([fieldName isEqualToString:@"Latitude"]) {
        tbl.latitude = fieldValue;
    } else if ([fieldName isEqualToString:@"Longitude"]) {
        tbl.longitude = fieldValue;
    } else if ([fieldName isEqualToString:@"Category"]) {
        tbl.cat1 = fieldValue;
    } else if ([fieldName isEqualToString:@"Student First Name"]) {
        tbl.firstName = fieldValue;
    } else if ([fieldName isEqualToString:@"Student Last Name"]) {
        tbl.lastName = fieldValue;
    } else if ([fieldName isEqualToString:@"Driver License Number"]) {
        tbl.driverLicenseNumber = fieldValue;
    } else if ([fieldName isEqualToString:@"Driver License State"]) {
        tbl.driverLicenseState = fieldValue;
    } else if ([fieldName isEqualToString:@"Instructor First Name"]) {
        tbl.instructorFirstName = fieldValue;
    } else if ([fieldName isEqualToString:@"Instructor Last Name"]) {
        tbl.instructorLastName = fieldValue;
    } else if ([fieldName isEqualToString:@"Instructor Employee Id"]) {
        tbl.instructorLastName = fieldValue;
    } else if ([fieldName isEqualToString:@"StartDateTime"]) {
        tbl.startDateTime = [self rcoStringToDateTime:fieldValue];
    } else if ([fieldName isEqualToString:@"EndDateTime"]) {
        tbl.endDateTime = [self rcoStringToDateTime:fieldValue];
    } else if ([fieldName isEqualToString:@"Elapsed Minutes"]) {
        tbl.elapsedMinutes = fieldValue;
    } else if ([fieldName isEqualToString:@"HeaderObjectId"]) {
        tbl.headerObjectId = fieldValue;
    } else if ([fieldName isEqualToString:@"HeaderObjectType"]) {
        tbl.headerObjectType = fieldValue;
    } else if ([fieldName isEqualToString:@"HeaderBarcode"]) {
        tbl.headerBarcode = fieldValue;
    }
}

- (void)getBreakLocationsForSudentDriverLicenseNumber:(NSString*)driverLicenseNumber andState:(NSString*)state forTraining:(NSString*)trainingObjectId {
    if (!driverLicenseNumber.length || !state.length) {
        return;
    }
    NSString *timestamp = @"+";
    NSArray *fieldsToReturn = @[@"StartDateTime", @"Latitude", @"Location", @"Longitude", @"HeaderBarcode"];

    NSString *params = [NSString stringWithFormat:@"%@/-%d/%@/+/+/+/%@,%@,%@/,/%@,%@,%@/,/+/%@", self.rcoRecordType, BATCH_SIZE, timestamp, @"Driver License Number", @"Driver License State", @"HeaderObjectId", driverLicenseNumber, state, trainingObjectId, [fieldsToReturn componentsJoinedByString:@","]];
    
    NSString *callId = [NSString stringWithFormat:@"%@_%@", driverLicenseNumber, state];
    
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: callId
                                         callBackTo: self];

}

-(NSArray*)getBreaksForTestMobileRecordId:(NSString*)testParentMobileRecordId orTestBarcode:(NSString*)testBarcode{
    
    if ((!testParentMobileRecordId.length) && (!testBarcode.length)) {
        return nil;
    }
    
    NSMutableArray *predicates = [NSMutableArray array];
    if (testParentMobileRecordId.length) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"rcoObjectParentId=%@", testParentMobileRecordId];
        [predicates addObject:p];
    }

    if (testBarcode.length) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"headerBarcode=%@", testBarcode];
        [predicates addObject:p];
    }

    NSArray *res = [self getAllNarrowedBy:[NSCompoundPredicate orPredicateWithSubpredicates:predicates] andSortedBy:nil];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"startDateTime" ascending:YES];
    return [res sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
}

-(NSArray*)getBreaksForDriverLicenseNumber:(NSString*)driverLicenseNumber andDriverLicenseState:(NSString*)state {
    if (!driverLicenseNumber.length || !state.length) {
        return nil;
    }
    NSMutableArray *predicates = [NSMutableArray array];
    if (driverLicenseNumber.length) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"driverLicenseNumber=%@", driverLicenseNumber];
        [predicates addObject:p];
    }

    if (state.length) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"driverLicenseState=%@", state];
        [predicates addObject:p];
    }
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"startDateTime" ascending:NO];
    res = [res sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
    if (!res.count) {
        return nil;
    }
    TrainingBreakLocation *ev = [res objectAtIndex:0];
    predicate = nil;
    
    if ([ev.headerObjectId doubleValue]){
        predicate = [NSPredicate predicateWithFormat:@"headerObjectId = %@", ev.headerObjectId];
    } else if (ev.rcoObjectParentId.length) {
        predicate = [NSPredicate predicateWithFormat:@"rcoObjectParentId = %@", ev.rcoObjectParentId];
    }
    
    if (predicate) {
        res = [res filteredArrayUsingPredicate:predicate];
    }
    return res;
}

- (void)requestFinished:(id )request {
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    
    NSString *msg = [msgDict objectForKey:@"message"];
    if ([msg isEqualToString:RD_G_R_U_X_F]) {
        
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];

        id respObject = nil;
        
        if ([request isKindOfClass:[NSDictionary class]]) {
            respObject = [request objectForKey:RESPONSE_OBJ];
        }
        
        if (respObject) {
            [result setObject:respObject forKey:RESPONSE_OBJ];
        }

        [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
    } else if([msg isEqualToString: TL]) {
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
    
    if([msg isEqualToString: TL]) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}


@end
