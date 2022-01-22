//
//  TestFormAggregate.h
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "Aggregate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestFormAggregate : Aggregate

-(NSArray*)getTestSections;
-(NSArray*)getTestItems:(NSString*)testNumber;
-(NSArray*)getTestForSection:(NSString*)section;
-(NSArray*)getTestForSections:(NSArray*)sections;
-(NSArray*)getTestsNames;
@end

NS_ASSUME_NONNULL_END
