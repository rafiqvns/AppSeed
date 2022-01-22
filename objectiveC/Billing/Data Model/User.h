//
//  User.h
//  MobileOffice
//
//  Created by .D. .D. on 12/14/15.
//  Copyright © 2015 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCOObject.h"

NS_ASSUME_NONNULL_BEGIN

#define UserTypeGrower @"grower"
#define UserTypeWorker @"worker"
#define UserTypeSalesPerson @"sales-person"
#define KEY_GrowerRecordId @"growerRecordId"

@interface User : RCOObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
