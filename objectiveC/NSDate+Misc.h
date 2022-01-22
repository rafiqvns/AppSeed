//
//  NSDate+Misc.h
//  NSDateTesting
//
//  Created by Thomas Smallwood on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define StartDate @"startDate"
#define EndDate @"endDate"

#define DateString_CustomDate @"CustomDate"
#define DateString_Today @"Today"
#define DateString_Yesterday @"Yesterday"
#define DateString_ThisWeek @"This Week"
#define DateString_LastWeek @"Last Week"
#define DateString_ThisMonth @"This Month"
#define DateString_LastMonth @"Last Month"
#define DateString_ThisYear @"This Year"
#define DateString_LastYear @"Last Year"

#define DateStringName @"DateStringName"

@interface NSDate (Misc)

// Removed so I could use PM Calendar
//+ (NSDate *)dateWithoutTime;
- (NSDate *)dateAsDateWithoutTime;
- (NSString *)formattedDateString;
- (NSString *)formattedMonthStringDayYear;
- (NSString *)formattedDateMonthDayString;
- (NSString *)ELDFormatDisplayString;
- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat;
+ (NSDate *)dateOfTheFirstFromDate:(NSDate *)date;
+ (NSInteger)firstDayOfTheMonth:(NSDate *)date;
+ (NSDate*)firstDayOfYear:(NSInteger)year;
+ (NSInteger)numberOfDaysInMonth:(NSDate *)date;
+ (NSInteger)numberOfDaysInPrevMonth:(NSDate *)date;
- (NSInteger)sharesMonthAsDate:(NSDate *)date;
- (BOOL)isTheSameDay:(NSDate *)date;
+ (NSInteger)monthAsNumber:(NSDate *)currentDate;
+ (NSInteger)yearAsNumber:(NSDate *)currentDate;
+ (NSString*)yearAsString:(NSDate *)currentDate;
+ (NSInteger)dayAsNumber:(NSDate *)currentDate;
+ (NSInteger)weekAsNumber:(NSDate *)currentDate;
+ (NSNumber *)hoursSinceDate:(NSDate *)date;

- (NSDate*)firstHourOfDayByAdding:(NSInteger)nrOfDays;
- (NSDate*)firstHourOfWeekByAdding:(NSInteger)nrOfWeeks;
- (NSDate*)firstHourOfYeayByAdding:(NSInteger)nrOfYears;
- (NSDate*)firstHourOfMonthByAdding:(NSInteger)nrOfMonths;
- (NSDate*)firstHourOfDay;

- (NSDate*)sharpHourFrom:(NSDate*)date;

- (NSInteger)weekNumber;
- (NSInteger)year;

- (NSDate*)firstDayOfWeek:(NSInteger)weekNr;
- (NSDate*)firstDayOfWeekFromDate:(NSDate*)date;
- (NSInteger)firstDayOfWeekAsNumber:(NSDate*)date;
- (NSInteger)weekDayAsNumber;

+ (NSDate*)easterDate:(NSInteger)year;
+ (NSDate*)moveToMondayIfSunday:(NSDate*)date;
+ (NSDate*)moveToMondayIfWeekend:(NSDate*) date;
+ (NSDate*)moveToWeekIfWeekend:(NSDate*) date;
+ (NSDate*)firstDayOfTheMonth:(NSInteger)month forYear:(NSInteger)year;
+ (NSDate*)daylightSavingTimeStartsForYear:(NSInteger)year;
+ (NSDate*)daylightSavingTimeEndsForYear:(NSInteger)year;
+ (NSDate*)dateByAddingDays:(NSInteger)days toDate:(NSDate*)date;
- (NSDate*)dateByAddingTime:(NSString*)time;

+ (NSDate*)dateByAddingYears:(NSInteger)years toDate:(NSDate*)date;
+ (NSDate*)dateFromComponents:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (NSDate*)SuperBawlSundayForYear:(NSInteger)year;

+ (NSInteger)dayRoshHashanah:(NSInteger)year;
+ (NSDate*)roshHashanah:(NSInteger)year;

+ (NSString*)YearMonthDay:(NSDate*)fromDate;
+ (NSString*)MonthDay:(NSDate*)fromDate;
+ (NSString*)YearMonth:(NSDate*)fromDate;

- (NSString*)dayAsString;
- (NSDate *) dateByAddingMonth_:(NSInteger)month;
- (NSDate*)dateWithoutSeconds;
- (NSDate*)dateWithoutMinutes;
- (NSString*)timeAsStringWithoutSeconds:(BOOL)showAMPM;
- (NSString*)timeAsStringWithoutSecondsWithoutAMPM;
- (NSDate *) toLocalTime;
- (NSString*)offlineMovingTimestamp;
- (NSString*)offlineMovingTimestamp24H;
- (NSInteger)hour;
- (NSString*)hoursMinutesSeconds;
- (NSString*)hoursMinutesForDriving;
- (NSString*)hoursMinutesForDriving2;
- (NSInteger)hoursMinutesSecondsAsNumber;

+ (NSNumber*)hoursBetweenTime:(NSString*)fromTime toTime:(NSString*)toTime;
- (NSString*)time;
- (NSString*)time24HourHormat;
- (NSString*)dateTime24HFormat;
+ (NSDictionary*)getStartEndIntervalsForOption:(NSString*)stringInterval;
- (NSString *) rcoDateRMSToString: (NSDate *) aDate;
+ (NSString *) rcoDateTimeString: (NSDate *) aDate;
- (NSInteger)currentNumberOfMinutes;
- (NSString *)formattedDayString;

+(NSArray*)dateOptions;
+ (NSString *) rcoDateDateToString: (NSDate *) aDate;

@end
