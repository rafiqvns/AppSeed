//
//  DriverEmployment+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 3/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//
//

#import "DriverEmployment+CoreDataClass.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"
#import "NSDate+Misc.h"

@implementation DriverEmployment

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

    //6 functionalGroupName
    [result addObject:@""];

    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];

    // 7 organisation name
    [result addObject:organizationName];

    //8 organisation number
    [result addObject:organizationId];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.lastEmployerName]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.lastEmployerAddress]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.lastEmployerCity]];
    
    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.lastEmployerState]];
    
    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.lastEmployerZipcode]];
    
    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.lastEmployerTelephoneNumber]];
    
    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.lastEmployerReasonsforleaving]];
    
    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.secondLastEmployerName]];
    
    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.secondLastEmployerAddress]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.secondLastEmployerCity]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.secondLastEmployerState]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.secondLastEmployerZipcode]];
    
    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.secondLastEmployerTelephoneNumber]];
    
    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.secondLastEmployerReasonsforleaving]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.thirdLastEmployerName]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.thirdLastEmployerAddress]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.thirdLastEmployerCity]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.thirdLastEmployerState]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.thirdLastEmployerZipcode]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.thirdLastEmployerTelephoneNumber]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.thirdLastEmployerReasonsforleaving]];

    //9 Date
    if (self.dateTime) {
        [result addObject:[self rcoDateTimeString:self.dateTime]];
    } else {
        [result addObject:@""];
    }

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.firstName]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.lastName]];

    //9 Are you injured
    [result addObject:[self getUploadCodingFieldFomValue:self.mobilePhone]];

    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
        
    return res;
}


@end
