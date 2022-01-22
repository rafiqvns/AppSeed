//
//  RCOObject.h
//  MobileOffice
//
//  Created by .D. .D. on 1/20/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define MANUFACTURER_SERIAL_NUMBER @"manufacturereSerialNumber"

NS_ASSUME_NONNULL_BEGIN

@interface RCOObject : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "RCOObject+CoreDataProperties.h"
