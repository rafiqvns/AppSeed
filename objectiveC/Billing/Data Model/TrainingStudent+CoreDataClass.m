//
//  TrainingStudent+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingStudent+CoreDataClass.h"
#import "RCOObject+RCOObject_Imp.h"
#import "Settings.h"

@implementation TrainingStudent

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
    
    //9 First Name
    [result addObject:[self getUploadCodingFieldFomValue:self.firstName]];

    //10 Middle Name
    [result addObject:[self getUploadCodingFieldFomValue:self.middleName]];

    //11 Last Name
    [result addObject:[self getUploadCodingFieldFomValue:self.lastName]];

    //12 Employee Id
    [result addObject:[self getUploadCodingFieldFomValue:self.employeeId]];

    //13 company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];

    //14 class
    [result addObject:[self getUploadCodingFieldFomValue:self.studentClass]];

    //15 endorsements
    [result addObject:[self getUploadCodingFieldFomValue:self.endorsements]];

    //16 driver license expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseExpirationDate]];

    //17 license number
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseNumber]];

    //17 license state
    [result addObject:[self getUploadCodingFieldFomValue:self.driverLicenseState]];

    //18 dot expiration date
    [result addObject:[self getUploadCodingFieldFomValue:self.dotExpirationDate1]];

    //19 corrective lens required
    [result addObject:[self getUploadCodingFieldFomValue:self.correctiveLensRequired]];

    //20 category 1 name
    [result addObject:[self getUploadCodingFieldFomValue:self.category1Name]];

    //21 category 1 value
    [result addObject:[self getUploadCodingFieldFomValue:self.category1Value]];

    //22 category 2 name
    [result addObject:[self getUploadCodingFieldFomValue:self.category2Name]];
    
    //23 category 2 value
    [result addObject:[self getUploadCodingFieldFomValue:self.category2Value]];

    //24 category 3 name
    [result addObject:[self getUploadCodingFieldFomValue:self.category3Name]];
    
    //25 category 3 value
    [result addObject:[self getUploadCodingFieldFomValue:self.category3Value]];

    //26 category 4 name
    [result addObject:[self getUploadCodingFieldFomValue:self.category4Name]];
    
    //27 category 4 value
    [result addObject:[self getUploadCodingFieldFomValue:self.category4Value]];

    //28 category 5 name
    [result addObject:[self getUploadCodingFieldFomValue:self.category5Name]];
    
    //21 category 5 value
    [result addObject:[self getUploadCodingFieldFomValue:self.category5Value]];
    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

-(NSString*)info {
    NSMutableArray *arr = [NSMutableArray array];
    if (self.lastName.length) {
        [arr addObject:self.lastName];
    }
    if (self.firstName.length) {
        [arr addObject:self.firstName];
    }
    if (self.studentId.length) {
        [arr addObject:self.studentId];
    }
    return [arr componentsJoinedByString:@","];
}

-(NSString*)Name {
    NSMutableArray *arr = [NSMutableArray array];
    if (self.lastName.length) {
        [arr addObject:self.lastName];
    }
    if (self.firstName.length) {
        [arr addObject:self.firstName];
    }
    if (self.middleName.length) {
        [arr addObject:self.middleName];
    }
    return [arr componentsJoinedByString:@","];
}

-(NSString*)customId {
    return self.studentId;
}

-(NSString*)Category {
    NSMutableArray *res = [NSMutableArray array];
    if (self.category1Name.length) {
        NSString *val = self.category1Value;
        if (!val) {
            val = @"";
        }
        [res addObject:[NSString stringWithFormat:@"%@: %@", self.category1Name, val]];
    }
    if (self.category2Name.length) {
        NSString *val = self.category2Value;
        if (!val) {
            val = @"";
        }
        [res addObject:[NSString stringWithFormat:@"%@: %@", self.category2Name, val]];
    }
    if (self.category3Name.length) {
        NSString *val = self.category3Value;
        if (!val) {
            val = @"";
        }
        [res addObject:[NSString stringWithFormat:@"%@: %@", self.category3Name, val]];
    }
    if (self.category4Name.length) {
        NSString *val = self.category4Value;
        if (!val) {
            val = @"";
        }
        [res addObject:[NSString stringWithFormat:@"%@: %@", self.category4Name, val]];
    }

    if (self.category5Name.length) {
        NSString *val = self.category5Value;
        if (!val) {
            val = @"";
        }
        [res addObject:[NSString stringWithFormat:@"%@: %@", self.category5Name, val]];
    }
    return [res componentsJoinedByString:@","];
}

@end

