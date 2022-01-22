//
//  DriverTurn+CoreDataClass.h
//  MobileOffice
//
//  Created by .D. .D. on 3/25/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "RCOObject.h"

#define DrivingTurnLeftShort @"left turn short"
#define DrivingTurnLeftWide @"left turn wide"
#define DrivingTurnLeftOk @"left turn ok"

/*
#define DrivingTurnLeftShort1 @"leftshort"
#define DrivingTurnLeftWide1 @"leftwide"
#define DrivingTurnLeftOk1 @"left"
*/

#define DrivingTurnRightShort @"right turn short"
#define DrivingTurnRightWide @"right turn wide"
#define DrivingTurnRightOk @"right turn ok"

#define DrivingTurnRightShort1 @"rightshort"
#define DrivingTurnRightWide1 @"rightwide"
#define DrivingTurnRightOk1 @"righ"

#define DriverTurnImageMapKey @"turnsMap"

NS_ASSUME_NONNULL_BEGIN

@interface DriverTurn : RCOObject
-(NSString*)CSVFormat;
+(NSString*)imagePathForStudentRecordId:(NSString*)recordId andDateTime:(NSDate*)dateTime;

@end

NS_ASSUME_NONNULL_END

#import "DriverTurn+CoreDataProperties.h"
