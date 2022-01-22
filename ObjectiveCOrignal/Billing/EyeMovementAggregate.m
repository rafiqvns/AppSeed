//
//  EyeMovementAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 4/15/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "EyeMovementAggregate.h"
#import "EyeMovement+CoreDataClass.h"
#import "DataRepository.h"

@implementation EyeMovementAggregate
- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"EyeMovement";
        self.rcoObjectClass = @"EyeMovement";
        self.rcoRecordType = @"Eye Movement";
        self.aggregateRight = kTrainingTestRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingRight, nil];
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
                                         callBackTo: self];
    
    return YES;
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue {
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
}

- (id) createNewRecord: (RCOObject *) obj {
    EyeMovement *form = (EyeMovement*)obj;
    
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
                                                  withMsg:EYE
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}
- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if ([msg isEqualToString: EYE]) {
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
    
    if ([msg isEqualToString: EYE]) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
    }
    return [super requestFailed:request];
}


@end
