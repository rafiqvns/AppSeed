//
//  DateSelectorViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 1/25/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddObject.h"

@interface DateSelectorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *_dates;
    NSMutableDictionary *_datesInfo;
    NSInteger _currentDateIndex;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) id<AddObject> selectDelegate;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, assign) BOOL shouldPopUpOnIpad;
@property (nonatomic, assign) BOOL showAllDaySwitch;
@property (nonatomic, assign) BOOL isTimePicker;
@property (nonatomic, assign) BOOL isSimpleDatePicker;
@property (nonatomic, strong) NSNumber *seconds;
@property (nonatomic, strong) NSDictionary *extraParameters;
@property (nonatomic, assign) NSInteger minuteStepper;
// if we want to send different names than the keys
@property (nonatomic, strong) NSArray *dateNames;
@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, assign) BOOL disableSelectInThePast;

/* 
 26.08.2016
 we should migrate to this
 */
@property (nonatomic, assign) BOOL isCancelNewLogic;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forDates:(NSArray*)dates;

@end
