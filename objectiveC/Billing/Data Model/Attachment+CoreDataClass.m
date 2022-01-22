//
//  Attachment+CoreDataClass.m
//  
//
//  Created by .D. .D. on 8/2/18.
//
//

#import "Attachment+CoreDataClass.h"
#import "DataRepository.h"
#import "Settings.h"

@implementation Attachment

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
    
    // 9 DateTime
    [res addObject:[self getUploadCodingFieldFomDateTime:self.dateTime]];

    // 10 Name
    [res addObject:[self getUploadCodingFieldFomValue:self.name]];

    // 11 Description
    [res addObject:[self getUploadCodingFieldFomValue:self.title]];

    // 12 ItemType
    [res addObject:[self getUploadCodingFieldFomValue:self.itemType]];

    // 13 ParentRecordId
    [res addObject:[self getUploadCodingFieldFomValue:[self parentRecordId]]];

    // 14 HeaderObjectId
    [res addObject:[self getUploadCodingFieldFomValue:self.parentObjectId]];

    // 15 HeaderObjectType
    [res addObject:[self getUploadCodingFieldFomValue:self.parentObjectType]];
    
    NSString *result = [res componentsJoinedByString:@"\",\""];
    result = [NSString stringWithFormat:@"\"%@\"", result];
    
    return result;
}

-(NSString*)parentRecordId {
    return self.parentBarcode;
}


@end
