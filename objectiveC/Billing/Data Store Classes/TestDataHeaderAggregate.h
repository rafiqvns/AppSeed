//
//  TestDataHeaderAggregate.h
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"

#define TDH @"TDH"
#define TestSignatureItemType @"CSD Test Signature"

NS_ASSUME_NONNULL_BEGIN

@class TestDataHeader;

@interface TestDataHeaderAggregate : Aggregate
-(TestDataHeader*)getStartedTestDataHeaderForTestInfo:(NSString*)testInfoMobileRecordId andFormNumber:(NSString*)formNumber;

-(void)getRecordAnalyticsAndGroupByCodingFields:(NSArray*)groupCodingFields
                           addCodingFieldsNames:(NSArray*)addCodingFieldNames
                                 withOperations:(NSArray*)operations
                                       fromDate:(NSDate*)fromDate
                                         toDate:(NSDate*)toDate
                                 dateRangeField:(NSString*)dateRangeField
                                   filterFields:(NSArray*)filterFields
                                   filterValues:(NSArray*)filterValues
                                  filterCompOps:(NSString*)filterCompOps
                                 namesDelimiter:(NSArray*)namesDelimiter
                                valuesDelimiter:(NSArray*)valuesDelimiter
                                  forRecordType:(NSString*)recordTypeParam
                                andAnaliticType:(NSString*)analyticType;

@end

NS_ASSUME_NONNULL_END
