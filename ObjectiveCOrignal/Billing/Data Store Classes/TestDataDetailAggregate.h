//
//  TestDataDetailAggregate.h
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"

NS_ASSUME_NONNULL_BEGIN

@class TestDataDetail;

@interface TestDataDetailAggregate : Aggregate
-(TestDataDetail*)getTestDetailForHeaderParentId:(NSString*)parentId forItemNumber:(NSString*)itemNumber andsectionNumber:(NSString*)sectionNumber;
@end

NS_ASSUME_NONNULL_END
