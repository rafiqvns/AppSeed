//
//  Note+CoreDataClass.h
//  MobileOffice
//
//  Created by .D. .D. on 1/4/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo+CoreDataClass.h"

#define Key_Note @"note"

NS_ASSUME_NONNULL_BEGIN

@interface Note : Photo

- (NSString*)CSVFormat;

@end

NS_ASSUME_NONNULL_END

#import "Note+CoreDataProperties.h"
