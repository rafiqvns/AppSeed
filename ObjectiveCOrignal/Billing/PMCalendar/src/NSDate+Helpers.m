//
//  NSDate+Helpers.m
//  PMCalendarDemo
//
//  Created by Pavel Mazurin on 7/14/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "NSDate+Helpers.h"

@implementation NSDate (Helpers)

- (NSDate *)dateWithoutTime
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitYear 
                                                          | NSCalendarUnitMonth 
                                                          | NSCalendarUnitDay ) 
                                                fromDate:self];
	
	return [calendar dateFromComponents:components];
}

- (NSDate *) dateByAddingDays:(NSInteger) days months:(NSInteger) months years:(NSInteger) years
{
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.day = days;
	dateComponents.month = months;
	dateComponents.year = years;
	
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                         toDate:self
                                                        options:0];    
}

- (NSDate *) dateByAddingDays:(NSInteger) days
{
    return [self dateByAddingDays:days months:0 years:0];
}

- (NSDate *) dateByAddingMonths:(NSInteger) months
{
    return [self dateByAddingDays:0 months:months years:0];
}

- (NSDate *) dateByAddingYears:(NSInteger) years
{
    return [self dateByAddingDays:0 months:0 years:years];
}

- (NSDate *) monthStartDate 
{
    NSDate *monthStartDate = nil;
	[[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth
                                    startDate:&monthStartDate 
                                     interval:NULL
                                      forDate:self];

	return monthStartDate;
}

- (NSUInteger) numberOfDaysInMonth
{
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay 
                                              inUnit:NSCalendarUnitMonth 
                                             forDate:self].length;
}

- (NSUInteger) weekday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:self];
    
    
    return [weekdayComponents weekday];
}

- (NSString *) dateStringWithFormat:(NSString *) format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
		
	return [formatter stringFromDate:self];
}


- (NSDate *) dateByAddingTimeFormatted:(NSString *) time {
    if ([time length] == 0) {
        // if there is no time then we shoul dreturn the same date
        return self;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *format = @"dd/MM/yyyy HH:mm:ss";
    [dateFormatter setDateFormat:format];

    NSString *dateTime = [NSString stringWithFormat:@"%@ %@",[self dateStringWithFormat:@"dd/MM/yyyy"], time];
    return [dateFormatter dateFromString:dateTime];
}

@end
