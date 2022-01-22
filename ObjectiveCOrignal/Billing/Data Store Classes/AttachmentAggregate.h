//
//  AttachmentAggregate.h
//  MobileOffice
//
//  Created by .D. .D. on 8/2/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import "Aggregate.h"

#define SA @"SA"

@interface AttachmentAggregate : Aggregate
- (void)getAttachmentsForParent:(NSString*)parentRecordId;
- (void)getAttachmentsForSudentDriverLicenseNumber:(NSString*)driverLicenseNumber andState:(NSString*)state;
-(NSArray*)getAttachmentsForObject:(NSString*)objRecordId;
-(NSArray*)getAttachmentsForStudentWithDriverLicenseNumber:(NSString*)licenseNumber andState:(NSString*)state;
@end
