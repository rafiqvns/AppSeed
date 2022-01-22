//
//  TrainingCompany+CoreDataProperties.h
//  CSD
//
//  Created by .D. .D. on 12/27/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingCompany+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrainingCompany (CoreDataProperties)

+ (NSFetchRequest<TrainingCompany *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *category1Name;
@property (nullable, nonatomic, copy) NSString *category1Value;
@property (nullable, nonatomic, copy) NSString *category2Name;
@property (nullable, nonatomic, copy) NSString *category2Value;
@property (nullable, nonatomic, copy) NSString *category3Name;
@property (nullable, nonatomic, copy) NSString *category3Value;
@property (nullable, nonatomic, copy) NSString *category4Name;
@property (nullable, nonatomic, copy) NSString *category4Value;
@property (nullable, nonatomic, copy) NSString *category5Name;
@property (nullable, nonatomic, copy) NSString *category5Value;
@property (nullable, nonatomic, copy) NSString *companyId;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *zip;
@property (nullable, nonatomic, copy) NSString *drivingSchool;

@end

NS_ASSUME_NONNULL_END
