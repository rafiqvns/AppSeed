//
//  Location+CoreDataClass.m
//  
//
//  Created by .D. .D. on 4/17/18.
//
//

#import "Location+CoreDataClass.h"

#import "DataRepository.h"
#import "Settings.h"
#import "RCOObject+RCOObject_Imp.h"


@implementation Location

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
    
    //9 location name
    if (self.name) {
        [result addObject:self.name];
    } else {
        [result addObject:@""];
    }
    
    //10 latitude
    if (self.latitude) {
        [result addObject:[NSString stringWithFormat:@"%@", self.latitude]];
    } else {
        [result addObject:@""];
    }
    
    //11 longitude
    if (self.longitude) {
        [result addObject:[NSString stringWithFormat:@"%@", self.longitude]];
    } else {
        [result addObject:@""];
    }
    
    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

@end
