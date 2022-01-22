//
//  TestDataDetail+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 12/12/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TestDataDetail+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TestDataDetail (CoreDataProperties)

+ (NSFetchRequest<TestDataDetail *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *employeeId;
@property (nullable, nonatomic, copy) NSString *employeeRecordId;
@property (nullable, nonatomic, copy) NSString *instructorEmployeeId;
@property (nullable, nonatomic, copy) NSString *instructorFirstName;
@property (nullable, nonatomic, copy) NSString *instructorLastName;
@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, copy) NSString *odometer;
@property (nullable, nonatomic, copy) NSString *score;
@property (nullable, nonatomic, copy) NSString *studentFirstName;
@property (nullable, nonatomic, copy) NSString *studentLastName;
@property (nullable, nonatomic, copy) NSString *testItemName;
@property (nullable, nonatomic, copy) NSString *testItemNumber;
@property (nullable, nonatomic, copy) NSString *testName;
@property (nullable, nonatomic, copy) NSString *testNumber;
@property (nullable, nonatomic, copy) NSString *testSectionName;
@property (nullable, nonatomic, copy) NSString *testSectionNumber;
@property (nullable, nonatomic, copy) NSString *testTeachingString;
@property (nullable, nonatomic, copy) NSString *trailerNumber;
@property (nullable, nonatomic, copy) NSString *leg;
@property (nullable, nonatomic, copy) NSString *equipmentUsedMobileRecordId;

@end

NS_ASSUME_NONNULL_END
