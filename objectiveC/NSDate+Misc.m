//
//  NSDate+Misc.m
//  NSDateTesting
//
//  Created by Thomas Smallwood on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Misc.h"

@implementation NSDate (Misc)

// Removed so I could use PM Calendar
/*+ (NSDate *)dateWithoutTime
{
    return [[NSDate date] dateAsDateWithoutTime];
}
*/
- (NSDate *)dateAsDateWithoutTime
{
    NSString *formattedString = [self formattedDateString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE MMM dd, yyyy"];
    NSDate *ret = [formatter dateFromString:formattedString];
    return ret;
}

- (NSString *)formattedMonthStringDayYear
{
    return [self formattedStringUsingFormat:@"MMM dd yyyy"];
}

- (NSString *)formattedDateString
{
    return [self formattedStringUsingFormat:@"EEE MMM dd, yyyy"];
}

- (NSString *)formattedDateMonthDayString
{
    return [self formattedStringUsingFormat:@"MMM dd"];
}

- (NSString *)ELDFormatDisplayString
{
    return [self formattedStringUsingFormat:@"dd-MMM-yy"];
}

- (NSString *)formattedDayString
{
    return [self formattedStringUsingFormat:@"EEE"];
}

- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

+ (NSDate *)dateOfTheFirstFromDate:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:0];
    [components setMonth:[dateComponents month]];
    [components setYear:[dateComponents year]];
    [components setHour:0];    
    
    NSDate *firstDayDate = [gregorian dateFromComponents:components];
    
    
    
    return firstDayDate;
}

//returned as an integer (ie. 1 = Sunday, 2 = Monday....)
+ (NSInteger)firstDayOfTheMonth:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:[dateComponents month]];
    [comps setYear:[dateComponents year]];
    [comps setHour:1];

    NSDate *firstDayDate = [gregorian dateFromComponents:comps];
    
    
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:firstDayDate];
    NSInteger weekday = [weekdayComponents weekday];
    
    return weekday;
}

+ (NSInteger)numberOfDaysInMonth:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSRange range = [gregorian rangeOfUnit:NSCalendarUnitDay
                                    inUnit:NSCalendarUnitMonth
                                   forDate:date];
    
    return range.length;
}

+ (NSInteger)numberOfDaysInPrevMonth:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:-1];
    
    NSDate *lastMonthDate = [gregorian dateByAddingComponents:offsetComponents toDate:date options:0];
    
    NSRange range = [gregorian rangeOfUnit:NSCalendarUnitDay
                                    inUnit:NSCalendarUnitMonth
                                   forDate:lastMonthDate];
    
    
    return range.length;
}

//returns -1 if date passed in has a month before date
//returns 0 if date passed in shares the month of date
//returns 1 if date passed in has a month after date
- (NSInteger)sharesMonthAsDate:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self];
    
    NSDateComponents *dateComponentsOfComparingDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    
    
    if ([dateComponentsOfComparingDate year] < [dateComponentsOfCurrentDate year]) {
        return -1;
    }
    else if ([dateComponentsOfComparingDate year] > [dateComponentsOfCurrentDate year]) {
        return 1;
    }
    else {
        if ([dateComponentsOfComparingDate month] == [dateComponentsOfCurrentDate month]) {
            return 0;
        }
        else if ([dateComponentsOfComparingDate month] < [dateComponentsOfCurrentDate month]) {
            return -1;
        }
        else {
            return 1;
        }
    }
}

- (BOOL)isTheSameDay:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:self];
    NSDateComponents *dateComponentsOfComparingDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:date];
    
    
    if (([dateComponentsOfCurrentDate year] == [dateComponentsOfComparingDate year]) && 
        ([dateComponentsOfCurrentDate month] == [dateComponentsOfComparingDate month]) && 
        ([dateComponentsOfCurrentDate day] == [dateComponentsOfComparingDate day])) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSDate*)firstHourOfDayByAdding:(NSInteger)nrOfDays {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:self];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dateComponentsOfCurrentDate.day + nrOfDays];
    [dateComponents setMonth:dateComponentsOfCurrentDate.month];
    [dateComponents setYear:dateComponentsOfCurrentDate.year];
    
    NSDate *newDate = [gregorian dateFromComponents:dateComponents];

    return newDate;
}

- (NSDate*)firstHourOfDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond) fromDate:self];
    [dateComponentsOfCurrentDate setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dateComponentsOfCurrentDate.day];
    [dateComponents setMonth:dateComponentsOfCurrentDate.month];
    [dateComponents setYear:dateComponentsOfCurrentDate.year];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [dateComponents setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate *newDate = [gregorian dateFromComponents:dateComponents];
    
    return newDate;
}

- (NSDate*)sharpHourFrom:(NSDate*)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitHour) fromDate:self];
    [dateComponentsOfCurrentDate setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dateComponentsOfCurrentDate.day];
    [dateComponents setMonth:dateComponentsOfCurrentDate.month];
    [dateComponents setYear:dateComponentsOfCurrentDate.year];
    [dateComponents setHour:dateComponentsOfCurrentDate.hour];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [dateComponents setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate *newDate = [gregorian dateFromComponents:dateComponents];
    
    return newDate;
}

- (NSDate*)firstHourOfWeekByAdding:(NSInteger)nrOfWeeks {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:( NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitDay ) fromDate:self];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dateComponentsOfCurrentDate.day  - (dateComponentsOfCurrentDate.weekday -1 ) + nrOfWeeks*7];
    [dateComponents setMonth:dateComponentsOfCurrentDate.month];
    [dateComponents setYear:dateComponentsOfCurrentDate.year];
    
    NSDate *newDate = [gregorian dateFromComponents:dateComponents];
    
    return newDate; 
}

- (NSDate*)firstDayOfWeek:(NSInteger)weekNr {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:( NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitWeekOfYear | NSCalendarUnitYearForWeekOfYear ) fromDate:self];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setWeekOfYear:weekNr];
    [dateComponents setYearForWeekOfYear:dateComponentsOfCurrentDate.yearForWeekOfYear];
        
    NSDate *newDate = [gregorian dateFromComponents:dateComponents];
    
    return newDate;
}

- (NSInteger)weekDayAsNumber{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:( NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitWeekOfYear | NSCalendarUnitYearForWeekOfYear ) fromDate:self];
    
    return dateComponentsOfCurrentDate.weekday;
}

- (NSDate*)firstDayOfWeekFromDate:(NSDate*)date {
    NSInteger weekNumber = [date weekNumber];
    return [date firstDayOfWeek:weekNumber];
}

- (NSInteger)weekNumber {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:( NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitWeekOfYear ) fromDate:self];
    return dateComponentsOfCurrentDate.weekOfYear;
}

- (NSInteger)year {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:( NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitWeekOfYear ) fromDate:self];
    return dateComponentsOfCurrentDate.year;
}

- (NSInteger)firstDayOfWeekAsNumber:(NSDate*)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:( NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitDay ) fromDate:date];
    return dateComponentsOfCurrentDate.day;
}

- (NSDate*)firstHourOfMonthByAdding:(NSInteger)nrOfMonths {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:( NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitDay ) fromDate:self];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:(dateComponentsOfCurrentDate.month + nrOfMonths)];
    [dateComponents setYear:dateComponentsOfCurrentDate.year];
    
    NSDate *newDate = [gregorian dateFromComponents:dateComponents];
    
    return newDate; 
}

- (NSDate*)firstHourOfYeayByAdding:(NSInteger)nrOfYears {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:( NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitDay ) fromDate:self];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:(dateComponentsOfCurrentDate.year + nrOfYears)];    
    NSDate *newDate = [gregorian dateFromComponents:dateComponents];
    
    return newDate; 
}

+ (NSInteger)monthAsNumber:(NSDate *)currentDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:currentDate];
    
    
    return [dateComponentsOfCurrentDate month];
}

- (NSDate *) dateByAddingMonth_:(NSInteger)month {
    NSDateComponents *c = [[NSDateComponents alloc] init];
    c.month = month;
    return [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:self options:0];
}

+ (NSInteger)yearAsNumber:(NSDate *)currentDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:currentDate];
    
    return [dateComponentsOfCurrentDate year];
}

+ (NSString*)yearAsString:(NSDate *)currentDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:currentDate];
    
    return [NSString stringWithFormat:@"%d", (int)[dateComponentsOfCurrentDate year]];
}
+ (NSInteger)dayAsNumber:(NSDate *)currentDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:currentDate];
    [dateComponentsOfCurrentDate setHour:0];
    
    return [dateComponentsOfCurrentDate day];
}

+ (NSInteger)weekAsNumber:(NSDate *)currentDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponentsOfCurrentDate = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:currentDate];
    [dateComponentsOfCurrentDate setHour:0];
    
    return [dateComponentsOfCurrentDate weekOfYear];
}

+ (NSNumber *)hoursSinceDate:(NSDate *)date {
    NSDate *currentDate = [NSDate date];
        
    NSTimeInterval timeDiff = [currentDate timeIntervalSinceDate:date];
    
    NSNumber *hoursSince = [NSNumber numberWithDouble:timeDiff / 3600];
    
    return hoursSince;
}

+ (NSDate*)easterDate:(NSInteger)year {
    
    NSInteger y = year;
    NSInteger a = y % 19;
    NSInteger b = y / 100;
    NSInteger c = y % 100;
    NSInteger d = b / 4;
    NSInteger e = b % 4;
    NSInteger f = (b + 8) / 25;
    NSInteger g = (b - f + 1) / 3;
    NSInteger h = (19 * a + b - d - g + 15) % 30;
    NSInteger i = c / 4;
    NSInteger k = c % 4;
    NSInteger l = (32 + 2 * e + 2 * i - h - k) % 7;
    NSInteger m = (a + 11 * h + 22 * l) / 451;
    NSInteger month = (h + l - 7 * m + 114) / 31;
    NSInteger day = ((h + l - 7 * m + 114) % 31) + 1;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:day];
    [dateComponents setMonth:month];
    [dateComponents setYear:year];
    
    return [gregorian dateFromComponents:dateComponents];    
}

+(NSDate*)moveToMondayIfSunday:(NSDate*) date{
    
    NSInteger wday = [NSDate  dayAsNumber:date];
    
    if (wday == 0) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:1];
        NSDate *newdate = [gregorian dateByAddingComponents:dateComponents 
                                                     toDate:date 
                                                    options:1];        
        
        return  newdate;

    }
    return date;
}

+(NSDate*)moveToMondayIfWeekend:(NSDate*) date{
    
    NSInteger wday = [NSDate  dayAsNumber:date];
    
    NSInteger day = 0;
    
    if (wday == 0) {
        day = 1;
    }
    
    if (wday == 6) {
        day = 2;
    }
        
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:day];
    NSDate *newdate = [gregorian dateByAddingComponents:dateComponents 
                                                 toDate:date 
                                                options:1];        
        
    return newdate;
}

+(NSDate*)moveToWeekIfWeekend:(NSDate*) date{
    
    NSInteger wday = [NSDate  dayAsNumber:date];
    
    NSInteger day = 0;
    
    if (wday == 1) {
        day = 1;
    }
    
    if (wday == 7) {
        day = -1;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:day];
    NSDate *newdate = [gregorian dateByAddingComponents:dateComponents 
                                                 toDate:date 
                                                options:1];        
    
    return newdate;
}


+(NSDate*)firstDayOfTheMonth:(NSInteger)month forYear:(NSInteger)year {
 
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:1];
    [dateComponents setMonth:month];
    [dateComponents setYear:year];
    
    return [gregorian dateFromComponents:dateComponents];
}

+(NSDate*)dateFromComponents:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:day];
    [dateComponents setMonth:month];
    [dateComponents setYear:year];
    
    return [gregorian dateFromComponents:dateComponents];
}

+ (NSDate*)daylightSavingTimeStartsForYear:(NSInteger)year {
    
    NSDate *date = [NSDate firstDayOfTheMonth:3 forYear:year];
    NSInteger numberOfday = [NSDate firstDayOfTheMonth:date];
    
    NSInteger rest = 1;
    
    if (numberOfday == 0) {
        rest = 7;
    } else {
        rest =  7 + ( 7 - numberOfday) + 1;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:rest];
    [dateComponents setHour:0];
    NSDate *newdate = [gregorian dateByAddingComponents:dateComponents 
                                                 toDate:date 
                                                options:0];        

    return newdate;
}

+ (NSDate*)daylightSavingTimeEndsForYear:(NSInteger)year {
    
    NSDate *date = [NSDate firstDayOfTheMonth:11 forYear:year];
    NSInteger numberOfday = [NSDate firstDayOfTheMonth:date];
    
    NSInteger rest = 0;
    
    if (numberOfday == 1) {
        rest = 0;
    } else {
        rest = 7 - numberOfday + 1;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:rest];
    NSDate *newdate = [gregorian dateByAddingComponents:dateComponents 
                                                 toDate:date 
                                                options:0];        
    
    return newdate;
}

- (NSDate*)dateByAddingTime:(NSString*)time {
    // time is in HH:mm:ss format or HH:mm
    NSArray *timeComponents = [time componentsSeparatedByString:@":"];
    if ([timeComponents count] == 3) {
        // hours, min and seconds
        NSInteger hours = [[timeComponents objectAtIndex:0] integerValue];
        NSInteger minutes = [[timeComponents objectAtIndex:1] integerValue];
        NSInteger seconds = [[timeComponents objectAtIndex:2] integerValue];
        NSTimeInterval timestamp = [self timeIntervalSince1970];
        timestamp += hours*60*60;
        timestamp += minutes*60;
        timestamp += seconds;
        return [NSDate dateWithTimeIntervalSince1970:timestamp];
    } else if ([timeComponents count] == 2) {
        // hours and minutes
        NSInteger hours = [[timeComponents objectAtIndex:0] integerValue];
        NSInteger minutes = [[timeComponents objectAtIndex:1] integerValue];
        NSTimeInterval timestamp = [self timeIntervalSince1970];
        timestamp += hours*60*60;
        timestamp += minutes*60;
        return [NSDate dateWithTimeIntervalSince1970:timestamp];
    }
    return self;
}

-(NSString*)hoursMinutesSeconds {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    return [dateFormat stringFromDate:self];
}

-(NSInteger)currentNumberOfMinutes {
    NSString *time = [self hoursMinutesSeconds];
    NSArray *comp = [time componentsSeparatedByString:@":"];
    if ([comp count] < 2) {
        return 0;
    }
    NSInteger *minutes = [[comp objectAtIndex:0] integerValue] * 60 + [[comp objectAtIndex:1] integerValue];
    return minutes;
}

-(NSString*)hoursMinutesForDriving {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    return [dateFormat stringFromDate:self];
}

- (NSInteger)hour {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH"];
    NSString *hourStr = [dateFormat stringFromDate:self];
    return [hourStr integerValue];
}

- (NSString*)hoursMinutesForDriving2 {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmmss"];
    return [dateFormat stringFromDate:self];
}

- (NSInteger)hoursMinutesSecondsAsNumber {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmmss"];
    NSString *strValue = [dateFormat stringFromDate:self];
    return  [strValue integerValue];
}


+ (NSDate*)dateByAddingYears:(NSInteger)years toDate:(NSDate*)date {

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:years];
    NSDate *newdate = [gregorian dateByAddingComponents:dateComponents
                                                 toDate:date
                                                options:0];
    
    return newdate;
}

+ (NSDate*)dateByAddingDays:(NSInteger)days toDate:(NSDate*)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:days];
    NSDate *newdate = [gregorian dateByAddingComponents:dateComponents 
                                                 toDate:date 
                                                options:0];        
    
    return newdate;
}

+ (NSDate*)firstDayOfYear:(NSInteger)year {

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:1];
    [dateComponents setMonth:1];
    [dateComponents setYear:year];
    
    return [gregorian dateFromComponents:dateComponents];
}

+ (NSDate*)SuperBawlSundayForYear:(NSInteger)year {
    
    NSDate *date = [NSDate firstDayOfTheMonth:2 forYear:year];
    NSInteger numberOfday = [NSDate firstDayOfTheMonth:date];
    
    NSInteger rest = 0;
    
    if (numberOfday == 1) {
        rest = 0;
    } else {
        rest = 7 - numberOfday + 1;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:rest];
    NSDate *newdate = [gregorian dateByAddingComponents:dateComponents 
                                                 toDate:date 
                                                options:0];        
    
    return newdate;
}


+(NSInteger)dayRoshHashanah:(NSInteger)year {
    
    NSInteger G = (year%19) + 1;
    NSInteger y = year-1900;
    
    //N + fraction = 6.057778996 + 1.554241797*Remainder(12G|19) + 0.25*Remainder(y|4) - 0.003177794*y,
    double n = 6.057778996 + 1.554241797*((12 *G) %19) + 0.25*(y % 4) - 0.003177794*y;
    
    /*
    //N + fraction = {[Y/100] - [Y/400] - 2} + 765433/492480*Remainder(12G|19) + Remainder(Y|4)/4 - (313Y+89081)/98496
    double value = (year*1.0)/100.0 - (year*1.0)/400.0 - 2;  
    double n = (value - (int)value) + 765433.0/492480.0*((12*G)%19) + (year%4)*1.0/4.0 - (313*year+89081.0)/98496.0;
    */
    double fraction = n - ((int)n);
        
    //23269/25920=0.898
    double k1 = 0.8977234;
    
    //1367/2160=0.633
    double k2 = 0.63287;
    
    
    NSDate *date = [NSDate firstDayOfTheMonth:9 forYear:year];
    date = [NSDate dateByAddingDays:(int)n toDate:date];
    
    NSInteger dayNumber = [NSDate firstDayOfTheMonth:date];
    
    NSLog(@" numberrr %d ---  nn = %d  %f", (int)dayNumber, (int) n, n);
    
    if (dayNumber == 1 || dayNumber == 4 || dayNumber == 6) {
        /*
         If the day calculated above is a Sunday, Wednesday, or Friday, Rosh Hashanah falls on the next day (Monday, Thursday or Saturday, respectively).
         */
        return ((int)n + 1);
    }
    
    if (dayNumber == 2) {
        /*
         If the calculated day is a Monday, and if the fraction is greater than or equal to 23269/25920, and if Remainder(12G|19) is greater than 11, Rosh Hashanah falls on the next day, a Tuesday.
         */
        NSInteger remainder = ((12*G) %19);
        if ((fraction >= k1) && (remainder > 11)) {
            return ((int)n + 1);
        }
    }
    
    if (dayNumber == 3) {
        /*
         If it is a Tuesday, and if the fraction is greater than or equal to 1367/2160, and if Remainder(12G|19) is greater than 6, Rosh Hashanah falls two days later, on Thursday (NOT WEDNESDAY!!).
         */
        NSInteger remainder = ((12*G) %19);
        if ((fraction >= k2) && (remainder > 6)) {
            return ((int)n + 2);
        }
    }
    
    return (int)n;
}

+ (NSDate*)roshHashanah:(NSInteger)year {
    
    NSCalendar *hebrew = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierHebrew];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:1];
    [dateComponents setMonth:7];
    [dateComponents setYear:year];
    
    return [hebrew dateFromComponents:dateComponents];
}

+(NSString*)YearMonthDay:(NSDate*)fromDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"YYYYMMdd"];
    
    return [dateFormatter stringFromDate:fromDate];
}

+(NSString*)YearMonth:(NSDate*)fromDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"YYYYMM"];
    
    return [dateFormatter stringFromDate:fromDate];
}

+(NSString*)MonthDay:(NSDate*)fromDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM"];
    
    return [dateFormatter stringFromDate:fromDate];
}


-(NSString*)dayAsString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormatter stringFromDate:self];
    
    return dayName;
}

-(NSDate*)dateWithoutSeconds {
    NSTimeInterval timestamp = [self timeIntervalSince1970];
    long long timestampWithoutseconds = timestamp / 60;
    
    NSDate *newdate = [NSDate dateWithTimeIntervalSince1970:timestampWithoutseconds *60];
    return newdate;
}

-(NSDate*)dateWithoutMinutes {
    NSTimeInterval timestamp = [self timeIntervalSince1970];
    long long timestampWithoutseconds = timestamp / (60 * 60);
    
    NSDate *newdate = [NSDate dateWithTimeIntervalSince1970:timestampWithoutseconds *60*60];
    return newdate;
}


-(NSString*)timeAsStringWithoutSeconds:(BOOL)showAMPM {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (showAMPM) {
        [formatter setDateFormat:@"hh:mm a"];
    } else {
        [formatter setDateFormat:@"hh:mm"];
    }
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

-(NSString*)timeAsStringWithoutSecondsWithoutAMPM {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}


-(NSDate *) toLocalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

-(NSString*)offlineMovingTimestamp {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}
-(NSString*)offlineMovingTimestamp24H {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

-(NSString*)dateTime24HFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}


-(NSString*)time {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

-(NSString*)time24HourHormat {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}


+ (NSNumber*)hoursBetweenTime:(NSString*)fromTime toTime:(NSString*)toTime {
    double fromSeconds = 0;
    NSArray *fromComponents = [fromTime componentsSeparatedByString:@":"];
    
    for (NSInteger i = 0; i < [fromComponents count]; i++) {
        NSString *val = [fromComponents objectAtIndex:i];
        fromSeconds *= 60;
        fromSeconds += [val doubleValue];
    }
    
    double toSeconds = 0;
    NSArray *toComponents = [toTime componentsSeparatedByString:@":"];

    for (NSInteger i = 0; i < [toComponents count]; i++) {
        NSString *val = [toComponents objectAtIndex:i];
        toSeconds *= 60;
        toSeconds += [val doubleValue];
    }

    double elapsedTime = toSeconds - fromSeconds;
    
    elapsedTime /= 3600;
    
    return [NSNumber numberWithDouble:elapsedTime];
}

+(NSDictionary*)getStartEndIntervalsForOption:(NSString*)stringInterval {
    
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    
    NSDate *startDate = nil;
    NSDate *endDate = nil;
    
    if ([stringInterval isEqualToString:DateString_Today]) {
        startDate = [[NSDate date] firstHourOfDayByAdding:0];
        endDate = [[NSDate date] firstHourOfDayByAdding:1];
    } else if ([stringInterval isEqualToString:DateString_Yesterday]) {
        startDate = [[NSDate date] firstHourOfDayByAdding:-1];
        endDate = [[NSDate date] firstHourOfDayByAdding:0];
    } else if ([stringInterval isEqualToString:DateString_ThisWeek]) {
        startDate = [[NSDate date] firstHourOfWeekByAdding:0];
        endDate = [[NSDate date] firstHourOfWeekByAdding:1];
    } else if ([stringInterval isEqualToString:DateString_LastWeek]) {
        startDate = [[NSDate date] firstHourOfWeekByAdding:-1];
        endDate = [[NSDate date] firstHourOfWeekByAdding:0];
    } else if ([stringInterval isEqualToString:DateString_ThisMonth]) {
        startDate = [[NSDate date] firstHourOfMonthByAdding:0];
        endDate = [[NSDate date] firstHourOfMonthByAdding:1];
    } else if ([stringInterval isEqualToString:DateString_LastMonth]) {
        startDate = [[NSDate date] firstHourOfMonthByAdding:-1];
        endDate = [[NSDate date] firstHourOfMonthByAdding:0];
    } else if ([stringInterval isEqualToString:DateString_ThisYear]) {
        startDate = [[NSDate date] firstHourOfYeayByAdding:0];
        endDate = [[NSDate date] firstHourOfYeayByAdding:1];
    } else if ([stringInterval isEqualToString:DateString_LastYear]) {
        startDate = [[NSDate date] firstHourOfYeayByAdding:-1];
        endDate = [[NSDate date] firstHourOfYeayByAdding:0];
    }

    if (startDate) {
        [res setObject:startDate forKey:StartDate];
    }
    
    if (endDate) {
        [res setObject:endDate forKey:EndDate];
    }
    
    return res;
}

- (NSString *) rcoDateRMSToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    
    return time_str;
}

+ (NSString *) rcoDateDateToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    
    return time_str;
}


+ (NSString *) rcoDateTimeString: (NSDate *) aDate
{
    if (!aDate) {
        return @"";
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *date_str =[dateFormat stringFromDate:aDate];
    
    return date_str;
}


+(NSArray*)dateOptions {
    return [NSArray arrayWithObjects:DateString_Today,DateString_Yesterday,DateString_ThisWeek, DateString_LastWeek, DateString_ThisMonth, DateString_LastMonth,DateString_ThisYear, DateString_LastYear, nil];
}
@end
