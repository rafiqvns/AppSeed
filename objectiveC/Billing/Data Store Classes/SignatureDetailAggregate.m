//
//  SignatureDetailAggregate.m
//  MobileOffice
//
//  Created by .D. .D. on 5/16/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import "SignatureDetailAggregate.h"

#import "SignatureDetail.h"
#import "DataRepository.h"
#import "Settings.h"

@implementation SignatureDetailAggregate

- (id) init {
    if ((self = [super init]) != nil){
        
        self.localObjectClass = @"SignatureDetail";
        self.rcoObjectClass = @"SignatureDetail";
        self.rcoRecordType = @"Signature";
        self.aggregateRight = kFormsRight;
        self.aggregateRights = [NSArray arrayWithObjects:self.aggregateRight, kTrainingTestRight, kTrainingRight, nil];
        _callsInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (Boolean) requestSync {
    
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];
        NSString *timestamp = @"99999999999999";
        NSString *params = [NSString stringWithFormat:@"%@/-%d/%@/+/+/+/%@/,/%@/,/+/+", self.rcoRecordType, BATCH_SIZE, timestamp, @"Master Barcode", @"1"];

        [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                                withMsg: RD_G_R_U_X_F
                                             withParams: params
                                              andObject: nil
                                             callBackTo: self];
    return YES;
}

- (void)getSignaturesForMasterBarcode:(NSString*)masterBarcode {
    NSString *params = [NSString stringWithFormat:@"%@/-%d/%lld/+/+/+/%@/,/%@/,/+/+", self.rcoRecordType, BATCH_SIZE,  [self.synchingTimeStamp longLongValue], @"Master Barcode", masterBarcode];
    [[DataRepository sharedInstance] askTheCloudFor: RD_S
                                            withMsg: RD_G_R_U_X_F
                                         withParams: params
                                          andObject: masterBarcode
                                         callBackTo: self];
}

-(void) syncObject: (RCOObject*)object withFieldName: (NSString *) fieldName toFieldValue: (NSString *) fieldValue
{
    [super syncObject: object withFieldName:fieldName toFieldValue:fieldValue];
    
    SignatureDetail *detail = (SignatureDetail *) object;
    
    if( [fieldName isEqualToString:@"Document Title"] )
    {
        detail.documentTitle = fieldValue;
        [detail addSearchString:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Issuing Authority"] )
    {
        detail.issuingAuthority = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Expiration Date"] )
    {
        detail.expirationDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Signature Name"] )
    {
        detail.signatureName = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Description"] )
    {
        detail.recordDescription = fieldValue;
    }
    else if( [fieldName isEqualToString:@"ItemType"] )
    {
        detail.itemType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Document Type"] )
    {
        detail.documentType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Document Date"] )
    {
        detail.documentDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"Reviewed By"] )
    {
        detail.reviewedBy = fieldValue;
    }
    else if( [fieldName isEqualToString:@"Reviewed Date"] )
    {
        detail.reviewedDate = [self rcoStringToDate:fieldValue];
    }
    else if( [fieldName isEqualToString:@"ParentObjectType"] )
    {
        detail.parentObjectType = fieldValue;
    }
    else if( [fieldName isEqualToString:@"ParentObjectId"] )
    {
        detail.parentObjectId = fieldValue;
    }
}

-(SignatureDetail*)getDetailForParentObjectId:(NSString*)parentId andType:(NSString*)documentTitle {
    // this uses the ParentObjectId from RMS
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentObjectId = %@ AND documentTitle = %@", parentId, documentTitle];
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    if ([res count]) {
        return [res objectAtIndex:0];
    }
    return nil;
}

-(NSArray*)getDetailsForParentObjectId:(NSString*)parentId {
    // this uses the ParentObjectId from RMS
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentObjectId = %@", parentId];
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    return res;
}

-(SignatureDetail*)getDetailForParentId:(NSString*)parentId andType:(NSString*)documentTitle {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rcoObjectParentId = %@ AND documentTitle = %@", parentId, documentTitle];
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    if ([res count]) {
        return [res objectAtIndex:0];
    }
    return nil;
}

-(SignatureDetail*)getDetailForParentBarcode:(NSString*)parentBarcode andType:(NSString*)documentTitle {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rcoBarcodeParent = %@ AND documentTitle = %@", parentBarcode, documentTitle];
    NSArray *res = [self getAllNarrowedBy:predicate andSortedBy:nil];
    
    if ([res count]) {
        return [res objectAtIndex:0];
    }
    return nil;
}

- (id ) createNewRecord: (RCOObject *) obj {

    SignatureDetail *sd = (SignatureDetail*)obj;
    
    if (!obj) {
        return nil;
    }
    
    if (!obj.rcoObjectId) {
        NSString *msg = [NSString stringWithFormat:@"Signature Detail object id is invalid! If the problem persists please contact RCO\n\nobj: %@\nOBJID: %@", obj, obj.rcoObjectId];
        [self showAlertMessage:msg];
        return nil;
    }
    
    BOOL parentSavedOnServer = !([sd.parentObjectId integerValue] == 0);
    
    if (!parentSavedOnServer) {
        NSString *parentObjectClass = sd.parentObjectType;
        NSString *parentMobileRecordId = sd.parentObjectId;
        
        if ([parentObjectClass length] == 0) {
            return nil;
        }
        
        if ([parentMobileRecordId length] == 0) {
            return nil;
        }
        
        Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:parentObjectClass];
        
        if (!agg) {
            return nil;
        }
        
        RCOObject *parentObject = [agg getObjectMobileRecordId:parentMobileRecordId];
        
        if (!parentObject) {
            return nil;
        }
        
        if (![parentObject existsOnServer]) {
            return nil;
        }
        
        sd.parentObjectId = parentObject.rcoObjectId;
        sd.parentObjectType = parentObject.rcoObjectType;
    }
    
    if (([sd.parentObjectType length] == 0) || ([sd.parentObjectId length] == 0) || !parentSavedOnServer) {
        return nil;
    }
    
    NSString *sdCSVFormat = [sd CSVFormat];

    NSData *data = [sdCSVFormat dataUsingEncoding:NSUTF8StringEncoding];
    
    [self dispatchToTheListeners: kObjectUploadStarted withObjectId:obj.rcoObjectId];
    
    [self setUploadingCallInfoForObject:obj];
    
    [obj setNeedsUploading:YES];
    [self save];
    
    return  [[DataRepository sharedInstance] tellTheCloud:F_S
                                                  withMsg:SS
                                               withParams:nil
                                                 withData:data
                                                 withFile:nil
                                                andObject:obj.rcoObjectId
                                               callBackTo:self];
}

- (void)requestFinished:(id )request {
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if([msg isEqualToString: SS] ) {
        
        NSString *rcoObjectId = [self parseSetRequest:request];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        
        if ([self isObjectIdValid:rcoObjectId]) {
            // upload the content of the signature
            SignatureDetail *sd = (SignatureDetail*)[self getObjectWithId:rcoObjectId];
            
            if ([sd.fileNeedsUploading boolValue]) {
                
                [self uploadRecordContent:sd];
            }
            
            [result setObject:rcoObjectId forKey:@"objId"];
            [self dispatchToTheListeners:kRequestSucceededForMessage withArg1:result withArg2:nil];
            [self dispatchToTheListeners:kObjectUploadComplete withObjectId:rcoObjectId];
        } else {
            [self requestFailed:request];
        }
    } else {
        return [super requestFinished:request];
    }
}

- (void)requestFailed:(id )request {
    NSString *response = [self getResponseStringFromRequest:request];
    
    NSDictionary *msgDict = [self getMsgDictFromRequestResponse:request];
    
    NSString *msg = [msgDict objectForKey:@"message"];
    
    if([msg isEqualToString: SS] ) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:msgDict];
        NSString *responseString = [self getResponseStringFromRequest:request];
        NSString *errorString = [self getErrorFromRequestResponse:request];
        
        if (responseString) {
            [resultDict setObject:responseString forKey:kMessageResponseKey];
        }
                
        [self dispatchToTheListeners:kRequestFailedForMessage withArg1:resultDict withArg2:nil];
        
    } else {
        return [super requestFailed:request];
    }
}

- (SignatureDetail *) createNewObject {
    SignatureDetail *sd = (SignatureDetail*)[super createNewObject];
    sd.itemType = self.itemType;
    return sd;
}

- (NSArray*) getObjectsThatNeedsToUpload {
    // we need to overwrite this
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(objectNeedsUploading == YES) AND (itemType == %@)", self.itemType];
    
    NSArray *array = [self getAllNarrowedBy:predicate andSortedBy:nil];
    
    if( [array count] ) {
        return array;
    }
    return nil;
    
}


@end
