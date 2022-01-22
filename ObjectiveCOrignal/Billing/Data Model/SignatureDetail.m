//
//  SignatureDetail.m
//  MobileOffice
//
//  Created by .D. .D. on 5/10/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import "SignatureDetail.h"

#import "DataRepository.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation SignatureDetail

// Insert code here to add functionality to your managed object subclass

-(NSString*)CSVFormat {
    NSMutableArray *result = [NSMutableArray array];
    
    if ([self existsOnServer]) {
        [result addObject:@"U"];
        [result addObject:@"H"];
        [result addObject:self.rcoObjectId];
        [result addObject:self.rcoObjectType];
        
    } else {
        [result addObject:@"O"];
        [result addObject:@"H"];
        [result addObject:@""];
        [result addObject:@""];
    }
    
    //5 MobileRecordId
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoMobileRecordId]];
    /*
  
    //6 functionalGroupName
    NSString *functionalGroupName = [[DataRepository sharedInstance].functionalRecordTypeMap objectForKey:@"Invoice Header"];
    
    if (functionalGroupName) {
        [result addObject:functionalGroupName];
    } else {
        [result addObject:@""];
    }
*/
    [result addObject:@""];

    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];
    
    // 7 organisation name
    [result addObject:organizationName];
    
    //8 organisation number
    [result addObject:organizationId];
    
    //9 document title
    [result addObject:[self getUploadCodingFieldFomValue:self.documentTitle]];
    
    //10 issuing authority
    [result addObject:[self getUploadCodingFieldFomValue:self.issuingAuthority]];
    
    //11 expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.expirationDate]];
    
    //12 signature date
    [result addObject:[self getUploadCodingFieldFomValue:self.signatureDate]];
    
    //13 signature name
    [result addObject:[self getUploadCodingFieldFomValue:self.signatureName]];
    
    //14 description
    [result addObject:[self getUploadCodingFieldFomValue:self.recordDescription]];
    
    //15 item type
    [result addObject:[self getUploadCodingFieldFomValue:self.itemType]];
    
    //16 document type
    [result addObject:[self getUploadCodingFieldFomValue:self.documentType]];
    
    //17 document date
    [result addObject:[self getUploadCodingFieldFomValue:self.documentDate]];
    
    //18 reviewed by
    [result addObject:[self getUploadCodingFieldFomValue:self.reviewedBy]];
    
    //19 reviewed date
    [result addObject:[self getUploadCodingFieldFomValue:self.reviewedDate]];

    //20 parent object id
    [result addObject:[self getUploadCodingFieldFomValue:self.parentObjectId]];

    //21 parent object type
    [result addObject:[self getUploadCodingFieldFomValue:self.parentObjectType]];
    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
