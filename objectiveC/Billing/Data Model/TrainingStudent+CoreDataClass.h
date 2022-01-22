//
//  TrainingStudent+CoreDataClass.h
//  CSD
//
//  Created by .D. .D. on 2/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "RCOObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrainingStudent : RCOObject
-(NSString*)info;
-(NSString*)Name;
-(NSString*)Category;
-(NSString*)CSVFormat;
@end

NS_ASSUME_NONNULL_END

#import "TrainingStudent+CoreDataProperties.h"
