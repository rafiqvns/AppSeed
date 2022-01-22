//
//  TrainingBreakLocationAggregate.h
//  CSD
//
//  Created by .D. .D. on 4/2/20.
//  Copyright © 2020 RCO. All rights reserved.
//

#import "Aggregate.h"

#define TL @"BL"

NS_ASSUME_NONNULL_BEGIN

@interface TrainingBreakLocationAggregate : Aggregate

- (void)getBreakLocationsForSudentDriverLicenseNumber:(NSString*)driverLicenseNumber andState:(NSString*)state forTraining:(NSString*)trainingObjectId; 
- (NSArray*)getBreaksForTestMobileRecordId:(NSString*)testParentMobileRecordId orTestBarcode:(NSString*)testBarcode;
- (NSArray*)getBreaksForDriverLicenseNumber:(NSString*)driverLicenseNumber andDriverLicenseState:(NSString*)state;

@end

NS_ASSUME_NONNULL_END
