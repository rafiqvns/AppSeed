//
//  Photo+CoreDataProperties.h
//  MobileOffice
//
//  Created by .D. .D. on 4/11/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "Photo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

+ (NSFetchRequest<Photo *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *parentBarcode;
@property (nullable, nonatomic, copy) NSString *parentObjectId;
@property (nullable, nonatomic, copy) NSString *parentObjectType;
@property (nullable, nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
