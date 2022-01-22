//
//  PMCalendarView.m
//  PMCalendarDemo
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMCalendarView.h"
#import "PMPeriod.h"
#import "PMCalendarConstants.h"
#import "NSDate+Helpers.h"
#import "NSDate+Misc.h"
#import "PMSelectionView.h"
#import "UIColor+TKCategory.h"
#import "NSDate+TKCategory.h"

@interface PMDaysView : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, assign) BOOL mondayFirstDayOfWeek;
@property (nonatomic, assign) BOOL showGrid;
@property (nonatomic, strong) NSArray *numberofEvents; // number of events
@property (nonatomic, assign) BOOL hideDaysFromNextMonth;
@property (nonatomic, assign) BOOL hideDaysFromPrevMonth;

- (void) redrawComponent;
@end

@interface PMCalendarView ()

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, strong) NSTimer *panTimer;
@property (nonatomic, assign) CGPoint panPoint;
@property (nonatomic, strong) PMDaysView *daysView;
@property (nonatomic, strong) PMSelectionView *selectionView;
@property (nonatomic, strong) NSDate *currentDate; // month to show

- (NSInteger) indexForDate: (NSDate *)date;
- (NSDate *) dateForPoint: (CGPoint)point;

@end

@implementation PMCalendarView
{
    NSInteger currentMonth;
    NSInteger currentYear;
    CGRect leftArrowRect;
    CGRect rightArrowRect;
    NSInteger fontSize;
}

@synthesize period = _period;
@synthesize allowedPeriod = _allowedPeriod;
@synthesize mondayFirstDayOfWeek = _mondayFirstDayOfWeek;
@synthesize currentDate = _currentDate;
@synthesize delegate = _delegate;
@synthesize font = _font;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize longPressGestureRecognizer = _longPressGestureRecognizer;
@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize longPressTimer = _longPressTimer;
@synthesize panTimer = _panTimer;
@synthesize panPoint = _panPoint;
@synthesize daysView = _daysView;
@synthesize selectionView = _selectionView;
@synthesize allowsPeriodSelection = _allowsPeriodSelection;
@synthesize allowsLongPressYearChange = _allowsLongPressYearChange;

- (void)dealloc
{
    self.numberofEvents = nil;
    [self.longPressTimer invalidate], self.longPressTimer = nil;
    [self.panTimer invalidate], self.panTimer = nil;
    _period = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame andType:(MonthViewType)type {
    
    if (type == MonthViewTypeGrid || type == MonthViewTypeGridNoExtraDays) {
        self.showGrid = YES;
    }
    _type = type;
    
    if (_type == MonthViewTypeGridNoExtraDays) {
        self.hideDaysFromNextMonth = YES;
        self.hideDaysFromPrevMonth = YES;
    }

    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame andType:(MonthViewType)type forEvents:(NSArray*)eventsInfo{
    
    if (type == MonthViewTypeGrid || type == MonthViewTypeGridNoExtraDays) {
        self.showGrid = YES;
        self.numberofEvents = eventsInfo;
    }
    _type = type;
    if (_type == MonthViewTypeGridNoExtraDays) {
        self.hideDaysFromNextMonth = YES;
        self.hideDaysFromPrevMonth = YES;
    }
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) 
    {
        return nil;
    }
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mondayFirstDayOfWeek = NO;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandling:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.numberOfTouchesRequired = 1;
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandling:)];
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.allowsLongPressYearChange = YES;

    self.selectionView = [[PMSelectionView alloc] initWithFrame:CGRectInset(self.bounds, -innerPadding.width, -innerPadding.height)];
    [self addSubview:self.selectionView];

    self.daysView = [[PMDaysView alloc] initWithFrame:self.bounds];    
    self.daysView.showGrid = self.showGrid;
    self.daysView.numberofEvents = self.numberofEvents;
    self.daysView.hideDaysFromNextMonth = self.hideDaysFromNextMonth;
    self.daysView.hideDaysFromPrevMonth = self.hideDaysFromPrevMonth;
    [self addSubview:self.daysView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redrawComponent)
                                                 name:kPMCalendarRedrawNotification
                                               object:nil];
    
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)redrawComponent
{
    NSLog(@"redrawComponent");
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *dayTitles = [dateFormatter shortStandaloneWeekdaySymbols];

    CGContextRef context = UIGraphicsGetCurrentContext();

//    CGColorRef shadow2 = [UIColor blackColor].CGColor;
//    CGFloat shadow2BlurRadius = 1;

    CGSize shadow2Offset = CGSizeMake(1, 1);

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    /*
    CGFloat hDiff  = width / 7;
    CGFloat vDiff  = (height - headerHeight) / 7;
     */
    
    int hDiff  = width / 7;
    int vDiff = 0;
    
    vDiff  = (height - headerHeight) / 7;
    vDiff  = (height - headerHeight) / 8;
    
    if (self.showMonthName) {
        headerHeight = 20;
    }
    
    BOOL isCurrentMonth = NO;
    
    if (self.showGrid) {
        NSDate *date = [NSDate date];
        if (([[date monthString] isEqualToString:[self.currentDate monthString]]) &&
            ([[date yearString] isEqualToString:[self.currentDate yearString]])) {
            
            CGRect headerFrame = CGRectMake(1,
                                            1,
                                            self.frame.size.width - 2,
                                            headerHeight + 18);

            
            UIBezierPath* selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:headerFrame cornerRadius: 0];
            CGContextSaveGState(context);
            [selectedRectPath addClip];
            //[[UIColor blueColor] setFill];
            [[UIColor eventTodayBackgroundColor] setFill];
            CGContextFillRect(context, headerFrame);
            CGContextRestoreGState(context);
            isCurrentMonth = YES;
        }
    }
    

    UIFont *calendarFont = self.font;
    
    if (self.showMonthName) {
        CGContextSaveGState(context);
        CGRect monthHeaderFrame = CGRectMake(5
                                           , 5
                                           , 200
                                           , 30);
        
        int month = currentMonth;
        int year = currentYear;
        NSArray *monthTitles = [dateFormatter standaloneMonthSymbols];
        NSString *monthTitle = [NSString stringWithFormat:@"%@ %d", [monthTitles objectAtIndex:(month - 1)], year];

        if (isCurrentMonth) {
            [[UIColor whiteColor] setFill];
        } else {
            [[UIColor darkGrayColor] setFill];
            //[[UIColor redColor] setFill];
        }

        double newFontSize = 0;
        
        if (DEVICE_IS_IPHONE) {
            newFontSize = 12;
        } else {
            newFontSize = 15;
        }
        
        [monthTitle drawInRect: monthHeaderFrame
                      withFont: [UIFont boldSystemFontOfSize:newFontSize]
                 lineBreakMode: UILineBreakModeWordWrap
                     alignment: NSTextAlignmentLeft];
        
        CGContextRestoreGState(context);

        headerHeight = 20;
    }

    for (int i = 0; i < dayTitles.count; i++)  {
        NSInteger index = i + (_mondayFirstDayOfWeek?1:0);
        index = index % 7;
        //// dayHeader Drawing
        CGContextSaveGState(context);
        //CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
        CGRect dayHeaderFrame = CGRectMake(floor(i * hDiff) - 1
                                           , headerHeight + (vDiff - self.font.pointSize) / 2 - shadow2Offset.height
                                           , hDiff
                                           , 30);
        if (self.showGrid) {
            if (isCurrentMonth) {
                [[UIColor whiteColor] setFill];
            } else {
                [[UIColor grayColor] setFill];
                //[[UIColor blueColor] setFill];
            }
        } else {
            [[UIColor lightGrayColor] setFill];
        }

        
        [((NSString *)[dayTitles objectAtIndex:index]) drawInRect: dayHeaderFrame
                                                         withFont: calendarFont 
                                                    lineBreakMode: UILineBreakModeWordWrap
                                                        alignment: NSTextAlignmentCenter];
        CGContextRestoreGState(context);
    }
        
	//// Month Header Drawing
    /*
     int month = currentMonth;
     int year = currentYear;
     NSArray *monthTitles = [dateFormatter standaloneMonthSymbols];
    NSString *monthTitle = [NSString stringWithFormat:@"%@ %d", [monthTitles objectAtIndex:(month - 1)], year];
     
     CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
    CGRect textFrame = CGRectMake(0
                                  , (headerHeight - [monthTitle sizeWithFont:monthFont].height) / 2
                                  , width
                                  , headerHeight);
    [[UIColor whiteColor] setFill];
    
    [monthTitle drawInRect: textFrame
                  withFont: monthFont
             lineBreakMode: UILineBreakModeWordWrap 
                 alignment: NSTextAlignmentCenter];
    
    CGContextRestoreGState(context);
    
    //// backArrow Drawing
    UIBezierPath* backArrowPath = [UIBezierPath bezierPath];
    [backArrowPath moveToPoint: CGPointMake(hDiff / 2 - 6
                                            , headerHeight / 2)];
    [backArrowPath addLineToPoint: CGPointMake(6 + hDiff / 2 - 6
                                               , headerHeight / 2 + 4)];
    [backArrowPath addLineToPoint: CGPointMake( 6 + hDiff / 2 - 6
                                               ,  headerHeight / 2 - 4)];
    [backArrowPath addLineToPoint: CGPointMake( hDiff / 2 - 6
                                               ,  headerHeight / 2)];
    [backArrowPath closePath];
    [[UIColor whiteColor] setFill];
    [backArrowPath fill];
    leftArrowRect = CGRectInset(backArrowPath.bounds, -20, -20);

    //// forwardArrow Drawing
    UIBezierPath* forwardArrowPath = [UIBezierPath bezierPath];
    [forwardArrowPath moveToPoint: CGPointMake( width - hDiff / 2 + 6
                                               ,  headerHeight / 2)];
    [forwardArrowPath addLineToPoint: CGPointMake( -6 + width - hDiff / 2 + 6
                                                  , headerHeight / 2 + 4)];
    [forwardArrowPath addLineToPoint: CGPointMake(-6 + width - hDiff / 2 + 6
                                                   , headerHeight / 2 - 4)];
    [forwardArrowPath addLineToPoint: CGPointMake( width - hDiff / 2 + 6
                                                  , headerHeight / 2)];
    [forwardArrowPath closePath];
    [[UIColor whiteColor] setFill];
    [forwardArrowPath fill];
    rightArrowRect = CGRectInset(forwardArrowPath.bounds, -20, -20);
     */
 
}

- (void) setCurrentDate:(NSDate *)currentDate
{
    _currentDate = currentDate;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *eComponents = [gregorian components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear 
                                                 fromDate:_currentDate];
    
    BOOL needsRedraw = YES;
    
    if([eComponents month] != currentMonth) 
    {
        currentMonth = [eComponents month];
        needsRedraw = YES;
    }
    if([eComponents year] != currentYear) 
    {
        currentYear = [eComponents year];
        needsRedraw = YES;
    }
    
    if (needsRedraw)
    {
        self.daysView.currentDate = currentDate;
        [self setNeedsDisplay];
        [self periodUpdated];
        if ([_delegate respondsToSelector:@selector(currentDateChanged:)])
        {
            [_delegate currentDateChanged:currentDate];
        }
    }
}

- (void)setMondayFirstDayOfWeek:(BOOL)mondayFirstDayOfWeek
{
    if (_mondayFirstDayOfWeek != mondayFirstDayOfWeek)
    {
        _mondayFirstDayOfWeek = mondayFirstDayOfWeek;
        self.daysView.mondayFirstDayOfWeek = mondayFirstDayOfWeek;
        [self setNeedsDisplay];
        [self periodUpdated];
        
        // Ugh... TODO: make other components redraw in more acceptable way
        if ([_delegate respondsToSelector:@selector(currentDateChanged:)])
        {
            [_delegate currentDateChanged:_currentDate];
        }
    }
}

- (void) setNumberofEvents:(NSArray *)numberofEvents
{
    if( _numberofEvents ) {
        _numberofEvents = nil;
    }
    
    _numberofEvents = numberofEvents;
    
    self.daysView.numberofEvents = numberofEvents;
    [self.daysView redrawComponent];
}

- (UIFont *) font
{
    NSInteger newFontSize = self.frame.size.width / 20;
    if (!_font || fontSize == 0 || fontSize != newFontSize)
    {
        _font = [UIFont fontWithName: @"Helvetica" size: newFontSize];
        self.daysView.font = _font;
        fontSize = newFontSize;
    }
    return _font;
}

- (void) periodUpdated
{
    NSInteger index = [self indexForDate:_period.startDate];
    NSInteger length = [_period lengthInDays];
    
    int numDaysInMonth      = [_currentDate numberOfDaysInMonth];
    NSDate *monthStartDate  = [_currentDate monthStartDate];
    NSInteger monthStartDay = [monthStartDate weekday];
    monthStartDay           = (monthStartDay + (self.mondayFirstDayOfWeek?5:6)) % 7;
    numDaysInMonth         += monthStartDay;
    int maxNumberOfCells    = ceil((CGFloat)numDaysInMonth / 7.0f) * 7 - 1;

    NSInteger endIndex = -1;
    NSInteger startIndex = -1;
    if (index <= maxNumberOfCells || index + length <= maxNumberOfCells)
    {
        endIndex = MIN( maxNumberOfCells, index + length );
        startIndex = MIN( maxNumberOfCells, index );
    }

    [self.selectionView setStartIndex:startIndex];
    [self.selectionView setEndIndex:endIndex];
}
- (void)setPeriod:(PMPeriod *)period
{
    if (![_period isEqual:period])
    {
        _period = period;
        
        if (!_currentDate)
        {
            self.currentDate = period.startDate;
        }
        
        if ([self.delegate respondsToSelector:@selector(periodChanged:)])
        {
            [self.delegate periodChanged:_period];
        }

        [self periodUpdated];
    }
}

- (void)selectDate:(NSDate*)dateToSelect {
    [self setCurrentDate:dateToSelect];
}

#pragma mark - Touches handling -

- (NSInteger) indexForDate: (NSDate *)date
{
    NSDate *monthStartDate  = [_currentDate monthStartDate];
    NSInteger monthStartDay = [monthStartDate weekday];
    monthStartDay           = (monthStartDay + (self.mondayFirstDayOfWeek?5:6)) % 7;

    NSInteger daysSinceMonthStart = [date timeIntervalSinceDate:monthStartDate] / (60 * 60 *24);
    return daysSinceMonthStart + monthStartDay;
}

- (NSDate *) dateForPoint: (CGPoint)point
{
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat hDiff  = width / 7;
    CGFloat vDiff  = (height - headerHeight) / 7;
    
    CGFloat yInCalendar = point.y - (headerHeight + vDiff);
    NSInteger row = yInCalendar / vDiff;
    
    int numDaysInMonth      = [_currentDate numberOfDaysInMonth];
    NSDate *monthStartDate  = [_currentDate monthStartDate];
    NSInteger monthStartDay = [monthStartDate weekday];
    monthStartDay           = (monthStartDay + (self.mondayFirstDayOfWeek?5:6)) % 7;
    numDaysInMonth         += monthStartDay;
    int maxNumberOfRows     = ceil((CGFloat)numDaysInMonth / 7.0f) - 1;
    
    row = MAX(0, MIN(row, maxNumberOfRows));
    
    CGFloat xInCalendar = point.x - 2;
    NSInteger col       = xInCalendar / hDiff;
    
    col = MAX(0, MIN(col, 6));
    
    NSInteger days = row * 7 + col - monthStartDay;
    NSDate *selectedDate = [monthStartDate dateByAddingDays:days];

    if (self.disableSelectDaysFromDifferentMonth) {
        if ([[selectedDate monthString] isEqualToString:[monthStartDate monthString]]) {
            return selectedDate;
        } else {
            // disable tapping on days that are not from the same month
            return nil;
        }
    } else {
        return selectedDate;
    }
}

- (void) periodSelectionStarted: (CGPoint) point
{
    NSDate *date = [self dateForPoint:point];
    if (date) {
        self.period = [PMPeriod oneDayPeriodWithDate:date];
    }
}

- (void) periodSelectionChanged: (CGPoint) point
{
    NSDate *newDate = [self dateForPoint:point];
    
    if (_allowsPeriodSelection)
    {
        self.period = [PMPeriod periodWithStartDate:self.period.startDate 
                                            endDate:newDate];
    }
    else
    {
        self.period = [PMPeriod oneDayPeriodWithDate:newDate];
    }
}

- (void) panTimerCallback: (NSTimer *)timer
{
    NSNumber *increment = timer.userInfo;
    
    [self setCurrentDate:[self.currentDate dateByAddingMonths:[increment intValue]]];
    [self periodSelectionChanged:_panPoint];
}

- (void) panHandling: (UIGestureRecognizer *)recognizer
{
    CGPoint point  = [recognizer locationInView:self];
    
    CGFloat height = self.frame.size.height;
    CGFloat vDiff  = (height - headerHeight) / 7;
    
    if (point.y > headerHeight + vDiff) // select date in calendar
    {
        if (([recognizer state] == UIGestureRecognizerStateBegan) && (recognizer.numberOfTouches == 1)) 
        {
            [self periodSelectionStarted:point];
        }
        else if (([recognizer state] == UIGestureRecognizerStateChanged) && (recognizer.numberOfTouches == 1))
        {
            if ((point.x < 20) || (point.x > self.frame.size.width - 20))
            {
                self.panPoint = point;
                if (self.panTimer)
                {
                    return;
                }
                
                NSNumber *increment = [NSNumber numberWithInt:1];
                if (point.x < 20)
                {
                    increment = [NSNumber numberWithInt:-1];
                }
                
                self.panTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                 target:self 
                                                               selector:@selector(panTimerCallback:)
                                                               userInfo:increment
                                                                repeats:YES];
            }
            else
            {
                [self.panTimer invalidate];
                self.panTimer = nil;
            }
            
            [self periodSelectionChanged:point];
        }
    }
    
    if (([recognizer state] == UIGestureRecognizerStateEnded) 
        || ([recognizer state] == UIGestureRecognizerStateCancelled)
        || ([recognizer state] == UIGestureRecognizerStateFailed))
    {
        [self.panTimer invalidate];
        self.panTimer = nil;
    }
}

- (void) tapHandling: (UIGestureRecognizer *)recognizer
{
    CGPoint point  = [recognizer locationInView:self];
    
    CGFloat height = self.frame.size.height;
    CGFloat vDiff  = (height - headerHeight) / 7;

    if (point.y > headerHeight + vDiff) // select date in calendar
    {
        [self periodSelectionStarted:point];
        [self setCurrentDate:self.period.startDate];
        return;
    }
    
    if(CGRectContainsPoint(leftArrowRect, point)) 
    {
        //User tapped the prevMonth button
        [self setCurrentDate:[self.currentDate dateByAddingMonths:-1]];
    } 
    else if(CGRectContainsPoint(rightArrowRect, point)) 
    {
        //User tapped the nextMonth button
        [self setCurrentDate:[self.currentDate dateByAddingMonths:1]];
    }
}

- (void) longPressTimerCallback: (NSTimer *)timer
{
    NSNumber *increment = timer.userInfo;
    
    [self setCurrentDate:[self.currentDate dateByAddingYears:[increment intValue]]];
}

- (void) longPressHandling: (UIGestureRecognizer *)recognizer
{
    if (([recognizer state] == UIGestureRecognizerStateBegan) && (recognizer.numberOfTouches == 1)) 
    {
        if (self.longPressTimer)
        {
            return;
        }

        CGPoint point = [recognizer locationInView:self];
        CGFloat height = self.frame.size.height;
        CGFloat vDiff  = (height - headerHeight) / 7;
        
        if (point.y > headerHeight + vDiff) // select date in calendar
        {
            [self periodSelectionChanged:point];
            return;
        }

        NSNumber *increment = nil;
        if(CGRectContainsPoint(leftArrowRect, point)) 
        {
            //User tapped the prevMonth button
            increment = [NSNumber numberWithInt:-1];
        } 
        else if(CGRectContainsPoint(rightArrowRect, point)) 
        {
            //User tapped the nextMonth button
            increment = [NSNumber numberWithInt:1];
        }

        if (increment)
        {
            self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                   target:self
                                                                 selector:@selector(longPressTimerCallback:)
                                                                 userInfo:increment 
                                                                  repeats:YES];
        }
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.longPressTimer)
        {
            return;
        }

        CGPoint point = [recognizer locationInView:self];
        [self periodSelectionChanged:point];
    }
    else if (([recognizer state] == UIGestureRecognizerStateCancelled) 
             || ([recognizer state] == UIGestureRecognizerStateEnded) )
    {
        if (self.longPressTimer)
        {
            [self.longPressTimer invalidate];
            self.longPressTimer = nil;
        }
        
        if( [recognizer state] == UIGestureRecognizerStateEnded ) {
            [self setCurrentDate:[self.period startDate]];
        }
    }
}

- (void)setAllowsLongPressYearChange:(BOOL)allowsLongPressYearChange
{
    if (!allowsLongPressYearChange)
    {
        if (self.longPressGestureRecognizer)
        {
            [self removeGestureRecognizer:self.longPressGestureRecognizer];
            self.longPressGestureRecognizer = nil;
        }
    }
    else if (!self.longPressGestureRecognizer)
    {
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(longPressHandling:)];
        self.longPressGestureRecognizer.numberOfTouchesRequired = 1;
        self.longPressGestureRecognizer.delegate = self;
        self.longPressGestureRecognizer.minimumPressDuration = 0.5;
        [self addGestureRecognizer:self.longPressGestureRecognizer];
    }
}

@end

@implementation PMDaysView

@synthesize font;
@synthesize currentDate = _currentDate;
@synthesize mondayFirstDayOfWeek = _mondayFirstDayOfWeek;

- (void)dealloc
{
    self.currentDate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)redrawComponent
{
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) 
    {
        return nil;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redrawComponent)
                                                 name:kPMCalendarRedrawNotification
                                               object:nil];

    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    ////NSLog(@"start draw rect");
  
    /*
    CGFloat hDiff  = width / 7;
    CGFloat vDiff  = (height - headerHeight) / 7;
    */
    
    
    int hDiff  = width / 7;
    
    if (self.showGrid) {
        //we show month name
        headerHeight = 20;
    }
    
    int vDiff  = (height - headerHeight) / 7;
    //int vDiff  = (height - headerHeight) / 8;

    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGColorRef shadow2 = [UIColor blackColor].CGColor;
//    CGFloat shadow2BlurRadius = 1;
    CGSize shadow2Offset = CGSizeMake(1, 1);

    void (^drawString)(NSString *, CGRect, UIColor *) = ^(NSString *string, CGRect rect, UIColor *color) {
        CGContextSaveGState(context);
        //CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
//        [UIColorMakeRGBA(arc4random()%255, arc4random()%255, arc4random()%255, 0.3) setFill];// \  Digits position
//        CGContextFillRect(context, rect);                                                    // /      debug
        
        [color setFill];
        [string drawInRect: rect
                  withFont: self.font
             lineBreakMode: UILineBreakModeWordWrap
                 alignment: NSTextAlignmentCenter];
        CGContextRestoreGState(context);
    };
    
    // digits drawing
    NSDate *today = [[NSDate date] dateWithoutTime];
    NSInteger todayMonth = [NSDate monthAsNumber:today];
    NSInteger todayYear = [NSDate yearAsNumber:today];
    NSInteger todayDay = [NSDate dayAsNumber:today];
    
    
    NSDate *dateOnFirst = [_currentDate monthStartDate];
	int weekdayOfFirst = ([dateOnFirst weekday] + (_mondayFirstDayOfWeek?5:6)) % 7 + 1;
	int numDaysInMonth = [dateOnFirst numberOfDaysInMonth];
        
    //Find number of days in previous month
    NSDate *prevDateOnFirst = [[_currentDate dateByAddingMonths:-1] monthStartDate];
    int numDaysInPrevMonth = [prevDateOnFirst numberOfDaysInMonth];
    
    if (!DEVICE_IS_IPAD) {
        //Draw the text for each of those days.
        if (!self.hideDaysFromPrevMonth) {
            for(int i = 0; i <= weekdayOfFirst-2; i++) {
                int day = numDaysInPrevMonth - weekdayOfFirst + 2 + i;
                
                NSString *string = [NSString stringWithFormat:@"%d", day];
                
                CGRect dayHeader2Frame = CGRectMake(floor((i%7) * hDiff) + 1
                                                    , headerHeight + (0 + 1) * vDiff + vDiff * (i/7) + (vDiff - self.font.pointSize) / 2 - shadow2Offset.height - 2
                                                    , floor(hDiff) - 1,
                                                    vDiff );
                
                if (self.showGrid) {
                    UIColor  *lighterGrayColor = [UIColor colorWithRed:224.0/255
                                                                 green:224.0/255
                                                                  blue:224.0/255
                                                                 alpha:1];
                    
                    UIBezierPath* selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:dayHeader2Frame cornerRadius: 0];
                    CGContextSaveGState(context);
                    [selectedRectPath addClip];
                    [lighterGrayColor setFill];
                    CGContextFillRect(context, dayHeader2Frame);
                    CGContextRestoreGState(context);
                    
                }
                
                UIColor *color = [UIColor colorWithWhite:0.85f alpha:1.0f];
                if( [NSDate monthAsNumber:prevDateOnFirst] == todayMonth && [NSDate yearAsNumber:prevDateOnFirst] == todayYear && day == todayDay ){
                    color = [UIColor blueColor];
                    color = [UIColor eventTodayBackgroundColor];
                }
                
                if (self.showGrid) {
                    color = [UIColor grayColor];
                }
                
                drawString( string, dayHeader2Frame, color );
            }
        }
    }
    
    NSDate *currentDateWithoutTime = [_currentDate dateWithoutTime];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:currentDateWithoutTime];
    NSInteger selectedDayDay = [components day];
    
	int finalRow    = 0;
	int day         = 1;
    
    NSInteger numberOfWeeks = 6;
    
    if (self.showGrid) {
        numberOfWeeks = 6;
    }
    
	for (int i = 0; i < numberOfWeeks; i++) 
    {
		for(int j = 0; j < 7; j++) 
        {
			int dayNumber = i * 7 + j;
            
			if(dayNumber >= (weekdayOfFirst-1) && day <= numDaysInMonth) {
                
                NSString *string = [NSString stringWithFormat:@"%d", day];
                CGRect dayHeader2Frame = CGRectMake(floor(j * hDiff) - 1
                                                    , headerHeight + (i + 1) * vDiff + (vDiff - self.font.pointSize) / 2 - shadow2Offset.height
                                                    , hDiff, self.font.pointSize);
                
                UIColor *color = nil;
                
                if( [NSDate monthAsNumber:dateOnFirst] == todayMonth && [NSDate yearAsNumber:dateOnFirst] == todayYear && day == todayDay )
                {
                    color = [UIColor colorWithRed: 0.98 green: 0.24 blue: 0.09 alpha: 1];
                    color = [UIColor blueColor];
                    color = [UIColor eventTodayBackgroundColor];
                }
                else 
                {
                    color = [UIColor whiteColor];
                    color = [UIColor grayColor];
                    //color = [UIColor greenColor];
                }
                
                if( selectedDayDay == day ) {
                     UIColor *backColor = [UIColor grayColor];
                    //backColor = [UIColor orangeColor];
                    
                    CGRect r;
                    NSInteger cornerRadius = 0;
                    if (self.showGrid) {
                        r = CGRectMake(floor(j*hDiff) + 1
                                       , headerHeight + ceil((i + 1)*vDiff + 1)
                                       , floor(hDiff) - 1, vDiff - 1);

                    } else {
                        r = CGRectMake(floor(j*hDiff) + 1.5
                                       , headerHeight + ceil((i + 1)*vDiff) + 2
                                       , floor(hDiff) - 4, vDiff - 4);
                        cornerRadius = 5;
                    }

                    UIBezierPath* selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius: cornerRadius];
                    CGContextSaveGState(context);
                    [selectedRectPath addClip];
                    [backColor setFill];
                    CGContextFillRect(context, r);
                    CGContextRestoreGState(context);
                                    
                    color=[UIColor whiteColor];
                    
                } else {
                    if (self.showGrid) {
                        UIColor *backColor = [UIColor whiteColor];
                        
                        NSString *dayString = [NSString stringWithFormat:@"%@%02d%02d",[self.currentDate yearString], [NSDate monthAsNumber:self.currentDate], day];
                        
                        NSPredicate *dayEventPredicate = [NSPredicate predicateWithFormat:@"eventDateName = %@", dayString];
                        
                        NSArray *eventsForDay = [self.numberofEvents filteredArrayUsingPredicate:dayEventPredicate];
                        if (eventsForDay.count > 0) {
                            
                            backColor = [UIColor yellowColor];

                            NSDictionary *eventInfo = [eventsForDay objectAtIndex:0];
                            
                            NSNumber *count = [eventInfo objectForKey:@"count"];
                            
                            if ([count integerValue] < 5) {
                                backColor = [UIColor yellowColor];
                            } else if ([count integerValue] < 10) {
                                backColor = [UIColor orangeColor];
                            } else if ([count integerValue] < 100){
                                backColor = [UIColor redColor];
                            }
                        }
                        
                        CGRect r = CGRectMake(floor(j*hDiff) + 1
                                              , headerHeight + ceil((i + 1)*vDiff + 1)
                                              , floor(hDiff) - 1, vDiff - 1);
                        
                        
                        
                        UIBezierPath* selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius: 0];
                        CGContextSaveGState(context);
                        [selectedRectPath addClip];
                        [backColor setFill];
                        CGContextFillRect(context, r);
                        CGContextRestoreGState(context);
                    }
                }
                                
                drawString( string, dayHeader2Frame, color );
                
                finalRow = i;
                
				++day;
			}
		}
	}
    
    //Find number of days in previous month
    NSDate *nextDateOnFirst = [[_currentDate dateByAddingMonths:+1] monthStartDate];
    
    int weekdayOfNextFirst = (weekdayOfFirst - 1 + numDaysInMonth) % 7;
    
    NSInteger numberofRemainingDays = 7;
    
    if (self.showGrid) {
        numberofRemainingDays += 7;
        if (weekdayOfNextFirst == 0) {
            // we should show one week from the next month
            /*
             why?????
             22.05.2014
            weekdayOfNextFirst = 7;
             */
        }
    }
    if (self.hideDaysFromNextMonth) {
        weekdayOfNextFirst = 0;
    }
    
    if (!DEVICE_IS_IPAD) {
        if( weekdayOfNextFirst > 0 )
        {
            //Draw the text for each of those days.
            for ( int i = weekdayOfNextFirst; i < numberofRemainingDays; i++ )
            {
                int day = i - weekdayOfNextFirst + 1;
                NSString *string = [NSString stringWithFormat:@"%d", day];
                CGRect dayHeader2Frame = CGRectMake(floor((i%7) * hDiff) + 1
                                                    , headerHeight + (finalRow + 1) * vDiff + vDiff * (i/7) + (vDiff - self.font.pointSize) / 2 - shadow2Offset.height - 2
                                                    , floor(hDiff) - 1,
                                                    vDiff );
                
                
                if (self.showGrid) {
                
                    UIColor  *lighterGrayColor = [UIColor colorWithRed:224.0/255
                                                                 green:224.0/255
                                                                  blue:224.0/255
                                                                 alpha:1];

                    UIBezierPath* selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:dayHeader2Frame cornerRadius: 0];
                    CGContextSaveGState(context);
                    [selectedRectPath addClip];
                    [lighterGrayColor setFill];
                    CGContextFillRect(context, dayHeader2Frame);
                    CGContextRestoreGState(context);
                    
                }

                
                UIColor *color = [UIColor colorWithWhite:0.85f alpha:1.0f];
                if( [NSDate monthAsNumber:nextDateOnFirst] == todayMonth && [NSDate yearAsNumber:nextDateOnFirst] == todayYear && day == todayDay ){
                    color = [UIColor blueColor];
                    color = [UIColor eventTodayBackgroundColor];
                }
                
                if (self.showGrid) {
                    color = [UIColor grayColor];
                }
                
                drawString( string, dayHeader2Frame, color );
            }
        }

    }
    //NSLog(@"end draw rect");
}

- (void) setCurrentDate:(NSDate *)currentDate
{
    if (![_currentDate isEqualToDate:currentDate])
    {
        _currentDate = currentDate;
        [self setNeedsDisplay];
    }
}

- (void)setMondayFirstDayOfWeek:(BOOL)mondayFirstDayOfWeek
{
    if (_mondayFirstDayOfWeek != mondayFirstDayOfWeek)
    {
        _mondayFirstDayOfWeek = mondayFirstDayOfWeek;
        [self setNeedsDisplay];
    }
}

@end
