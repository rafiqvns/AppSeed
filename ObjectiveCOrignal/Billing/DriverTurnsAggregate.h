//
//  DriverTurnsAggregate.h
//  MobileOffice
//
//  Created by .D. .D. on 3/25/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"

#define TURNS @"TURNS"

NS_ASSUME_NONNULL_BEGIN

@interface DriverTurnsAggregate : Aggregate

-(NSArray*)getTurnsForTest:(NSString*)testInfoMobileRecordId;
-(void)getTurnsForHeaderWithMobileRecordId:(NSString*)mobileRecordId;

@end

NS_ASSUME_NONNULL_END
