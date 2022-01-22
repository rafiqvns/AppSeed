//
//  Note+CoreDataClass.m
//  MobileOffice
//
//  Created by .D. .D. on 1/4/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import "Note+CoreDataClass.h"
#import "DataRepository.h"
#import "Settings.h"


@implementation Note
- (NSString*)CSVFormat {
    
    NSMutableArray *res = [NSMutableArray array];
    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];
    
    if ([self existsOnServerNew]) {
        [res addObject:@"U"];
        [res addObject:@"H"];
        [res addObject:self.rcoObjectId];
        [res addObject:self.rcoObjectType];
    } else {
        [res addObject:@"O"];
        [res addObject:@"H"];
        [res addObject:@""];
        [res addObject:@""];
    }
    
    // 5 MobileRecordId
    if (self.rcoMobileRecordId) {
        [res addObject:self.rcoMobileRecordId];
    } else {
        [res addObject:@""];
    }
    
    // 6 functionalGroupName
    [res addObject:@""];
    
    // 7 Organization Name
    [res addObject:organizationName];
    
    // 8 Organization Number
    [res addObject:organizationId];
    
    // 9 HeaderObjectId
    [res addObject:[self getUploadCodingFieldFomValue:self.parentObjectId]];
    
    // 10 HeaderObjectType
    [res addObject:[self getUploadCodingFieldFomValue:self.parentObjectType]];
    
    // 11 HeaderBarcode
    [res addObject:@""];
    
    // 12 Date
    [res addObject:[self getUploadCodingFieldFomDateTime:self.dateTime]];
    
    // 13 Title
    NSString *t = [self.title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [res addObject:[self getUploadCodingFieldFomValue:t]];
    
    // 14 Notes
    NSString *n = [self.notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    [res addObject:[self getUploadCodingFieldFomValue:n]];
    
    // 15 Location
    [res addObject:[self getUploadCodingFieldFomValue:self.name]];
    
    // 16 itemType
    [res addObject:ItemTypeNote];
    
    // 17 Latitude
    [res addObject:[self getUploadCodingFieldFomValue:self.latitude]];
    
    // 18 Longitude
    [res addObject:[self getUploadCodingFieldFomValue:self.longitude]];
    
    // 18 category
    [res addObject:[self getUploadCodingFieldFomValue:self.category]];

    // 19 UserRecordId in the case of Training this will be userRecordId
    [res addObject:[self getUploadCodingFieldFomValue:self.creatorRecordId]];
    
    NSString *result = [res componentsJoinedByString:@"\",\""];
    result = [NSString stringWithFormat:@"\"%@\"", result];
    
    return result;
}

-(NSString*)objectShortDescription {
    return self.notes;
}


@end
