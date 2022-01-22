//
//  TestForm+CoreDataClass.h
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "RCOObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestForm : RCOObject
-(NSArray*)getTestCategorieNames;
-(NSArray*)getTestCategorieValues;
@end

NS_ASSUME_NONNULL_END

#import "TestForm+CoreDataProperties.h"
