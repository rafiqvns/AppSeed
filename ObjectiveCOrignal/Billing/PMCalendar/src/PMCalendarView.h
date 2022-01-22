//
//  PMCalendarView.h
//  PMCalendarDemo
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MonthViewTypeBasic = 0,
    MonthViewTypeBasicWhite,
	MonthViewTypeGrid,
    MonthViewTypeGridNoExtraDays,
} MonthViewType;

@class PMPeriod;
@protocol PMCalendarViewDelegate;

/**
 * PMCalendarView is an internal class.
 *
 * PMCalendarView is a view which manages user's interactions - tap, pan and long press.
 * It also renders text (month, weekdays titles, days).
 */
@interface PMCalendarView : UIView <UIGestureRecognizerDelegate> {
    MonthViewType _type;
}

/**
 * Selected period. See PMCalendarController for more information.
 */
@property (nonatomic, strong) PMPeriod *period;

/**
 * Period allowed for selection. See PMCalendarController for more information.
 */
@property (nonatomic, strong) PMPeriod *allowedPeriod;

/**
 * Is monday a first day of week. See PMCalendarController for more information.
 */
@property (nonatomic, assign) BOOL mondayFirstDayOfWeek;

/**
 * Is period selection allowed. See PMCalendarController for more information.
 */
@property (nonatomic, assign) BOOL allowsPeriodSelection;

/**
 * Is long press allowed. See PMCalendarController for more information.
 */

@property (nonatomic, assign) BOOL allowsLongPressYearChange;
@property (nonatomic, weak) id<PMCalendarViewDelegate> delegate;

/*
 * Shows Month Name
 */
@property (nonatomic, assign) BOOL showMonthName;

/*
 * Shows grid
 */
@property (nonatomic, assign) BOOL showGrid;

/*
 * Hide Days from prev and next month
 */
@property (nonatomic, assign) BOOL hideDaysFromNextMonth;

@property (nonatomic, assign) BOOL hideDaysFromPrevMonth;


// event coloring
@property (nonatomic, strong) NSArray *numberofEvents; // number of events

@property (nonatomic, assign) BOOL disableSelectDaysFromDifferentMonth;


/*
 Custom init method
 */
- (id)initWithFrame:(CGRect)frame andType:(MonthViewType)type;

- (id)initWithFrame:(CGRect)frame andType:(MonthViewType)type forEvents:(NSArray*)eventsInfo;

- (void)selectDate:(NSDate*)dateToSelect;

@end

@protocol PMCalendarViewDelegate <NSObject>

/**
 * Called on the delegate when user changes showed month.
 */
- (void) currentDateChanged: (NSDate *)currentDate;

/**
 * Called on the delegate when user changes selected period.
 */
- (void) periodChanged: (PMPeriod *)newPeriod;

@end
