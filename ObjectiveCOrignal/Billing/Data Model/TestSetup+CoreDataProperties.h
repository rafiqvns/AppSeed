//
//  TestSetup+CoreDataProperties.h
//  Quality
//
//  Created by .D. .D. on 1/29/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TestSetup+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TestSetup (CoreDataProperties)

+ (NSFetchRequest<TestSetup *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *numberOfSections;
@property (nullable, nonatomic, copy) NSString *possiblePoints;
@property (nullable, nonatomic, copy) NSString *possibleSections;
@property (nullable, nonatomic, copy) NSString *sectionTitles;

@end

NS_ASSUME_NONNULL_END
