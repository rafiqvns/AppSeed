//
//  DateSelectorViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 1/25/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "DateSelectorViewController.h"
#import "DataRepository.h"
#import "NSDate+Misc.h"

@interface DateSelectorViewController ()
@property (nonatomic, strong) NSMutableDictionary *params;
@end

@implementation DateSelectorViewController

@synthesize currentDate;
@synthesize seconds;
@synthesize showAllDaySwitch;
@synthesize extraParameters;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forDates:(NSArray*)dates
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _dates = dates;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.params = [NSMutableDictionary dictionary];
    
    if (self.extraParameters) {
        [self.params addEntriesFromDictionary:self.extraParameters];
    }
    
    if (self.minuteStepper) {
        self.datePicker.minuteInterval = self.minuteStepper;
    }
    
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelPressed)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(donePressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    _datesInfo = [NSMutableDictionary new];
    
    if (self.disableSelectInThePast) {
        [self.datePicker setMinimumDate:[NSDate date]];
    } else {
        [self.datePicker setMinimumDate:self.minDate];
    }
    if (self.isTimePicker) {
        [self.datePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
        [self.datePicker setDatePickerMode:UIDatePickerModeTime];
        
        // 11.12.2018 to diable am/pm
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"da_DK"];
        [self.datePicker setLocale:locale];

        if (self.seconds) {
            [_datesInfo setObject:self.seconds forKey:@"time"];
        } else {
            [_datesInfo setObject:[NSNumber numberWithInt:1] forKey:@"time"];
            self.seconds = [NSNumber numberWithInteger:1];
        }
    } else if (self.isSimpleDatePicker) {
        self.datePicker.date = self.currentDate;
        NSString *option = [_dates objectAtIndex:_currentDateIndex];
        [_datesInfo setObject:self.currentDate forKey:option];
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    } else {
        
        if (!self.currentDate) {
            self.currentDate = [NSDate date];
        }
        self.datePicker.date = self.currentDate;

        NSString *option = [_dates objectAtIndex:_currentDateIndex];
        [_datesInfo setObject:self.currentDate forKey:option];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventPrimaryActionTriggered];
    if (self.isTimePicker) {
        [self.datePicker setCountDownDuration:[self.seconds integerValue]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    _dates = nil;
}

#pragma mark -
#pragma mark Actions

-(void)cancelPressed {
    
    if ([self.selectDelegate respondsToSelector:@selector(didSelectObject:forKey:)]) {
        [self.selectDelegate didSelectObject:[_datesInfo objectForKey:nil] forKey:nil];
    } else if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        if (self.isCancelNewLogic) {
            NSString *option = [_dates objectAtIndex:_currentDateIndex];
            [self.selectDelegate didAddObject:[_datesInfo objectForKey:nil] forKey:option];
        } else {
            [self.selectDelegate didAddObject:[_datesInfo objectForKey:nil] forKey:nil];
        }
    }

    if (DEVICE_IS_IPHONE){
        if (self.isCancelNewLogic) {
            // wes hould not send anything
            NSLog(@"");
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if (self.shouldPopUpOnIpad) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)donePressed {
    
    NSString *option = [_dates objectAtIndex:_currentDateIndex];
    
    if (!self.showAllDaySwitch) {
        // we don't have all day switch
        if ([self.selectDelegate respondsToSelector:@selector(didSelectObject:forKey:)]) {
            if (self.isTimePicker) {
                [self.selectDelegate didSelectObject:[_datesInfo objectForKey:@"time"] forKey:[_dates objectAtIndex:0]];
            } else {
                [self.selectDelegate didSelectObject:[_datesInfo objectForKey:option] forKey:option];
            }
        } else if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            if (self.isTimePicker) {
                [self.selectDelegate didAddObject:[_datesInfo objectForKey:@"time"] forKey:[_dates objectAtIndex:0]];
            } else {
                [self.selectDelegate didAddObject:[_datesInfo objectForKey:option] forKey:option];
            }
        }
    }
    else {
        // we have all day switch
        if ([self.selectDelegate respondsToSelector:@selector(didSelectObjects:forKeys:)]) {
            NSMutableArray *objects = [NSMutableArray array];
            NSMutableArray *keys = [NSMutableArray array];
            
            NSNumber *allDay = [self.params objectForKey:@"allDay"];
            
            if (allDay) {
                [objects addObject:allDay];
                [keys addObject:@"allDay"];
            
                if ([allDay boolValue]) {
                    
                    NSDate *date = [_datesInfo objectForKey:option];
                    date = [date firstHourOfDay];
                    date = [date dateByAddingTimeInterval:23*60*60 + 59*60];
                    
                    [objects addObject:date];
                    [keys addObject:@"End Date"];
                }            
            }
            
            if (self.isTimePicker) {
                [objects addObject:[_datesInfo objectForKey:@"time"]];
                [keys addObject:[_dates objectAtIndex:0]];

                [self.selectDelegate didSelectObjects:objects forKeys:keys];
            } else {
                
                [objects addObject:[_datesInfo objectForKey:option]];
                [keys addObject:option];
                                
                [self.selectDelegate didSelectObjects:objects forKeys:keys];
            }
        } else if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            
            NSMutableArray *objects = [NSMutableArray array];
            NSMutableArray *keys = [NSMutableArray array];
            
            NSNumber *allDay = [self.params objectForKey:@"allDay"];
            
            if (allDay) {
                [objects addObject:allDay];
                [keys addObject:@"allDay"];
                
                if ([allDay boolValue]) {
                    
                    NSDate *date = [_datesInfo objectForKey:option];
                    date = [date firstHourOfDay];
                    date = [date dateByAddingTimeInterval:23*60*60 + 59*60];
                    
                    [objects addObject:date];
                    [keys addObject:@"End Date"];
                }
                
            }
            
            if (self.isTimePicker) {
                
                [objects addObject:[_datesInfo objectForKey:@"time"]];
                [keys addObject:[_dates objectAtIndex:0]];
                
                [self.selectDelegate didAddObjects:objects forKeys:keys];
            } else {
                [objects addObject:[_datesInfo objectForKey:option]];
                [keys addObject:option];
                
                if ([self.selectDelegate respondsToSelector:@selector(didAddObjects:forKeys:)]) {
                    [self.selectDelegate didAddObjects:objects forKeys:keys];
                }
            }
        }
    }
    
    if (DEVICE_IS_IPHONE) {
        if (self.isCancelNewLogic) {
            /*
             26.08.2016, the new logic ...
             */
            NSLog(@"");
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if (self.shouldPopUpOnIpad) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.showAllDaySwitch) {
        return [_dates count] + 1;
    } else {
        return [_dates count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellItentifier = @"DateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellItentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellItentifier];
    }
    
    if (indexPath.row < _dates.count) {
        if (self.isTimePicker) {
            NSInteger secondsValue = [[_datesInfo objectForKey:@"time"] integerValue];
            NSInteger hoursVal = secondsValue / 3600;
            secondsValue = secondsValue % 3600;
            NSInteger minutesVal = secondsValue /60;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)hoursVal, (int)minutesVal];
        } else {
            NSString *option = [_dates objectAtIndex:indexPath.row];
            
            if (indexPath.row < self.dateNames.count) {
                NSString *optionName = [self.dateNames objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@", optionName];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@", option];
            }
            
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            
            NSDate *date = [_datesInfo objectForKey:option];
            if (self.isSimpleDatePicker) {
                cell.detailTextLabel.text = [self rcoDateToString:date];
            } else {
                cell.detailTextLabel.text = [self rcoDateAndTimeToString:date];
                cell.detailTextLabel.text = [self rcoDateAndTimeToStringNoSeconds:date];
            }
        }
        cell.accessoryView = nil;
    } else {
        // add all day switch
        NSNumber *allDay = [self.params objectForKey:@"allDay"];
        UISwitch *allDaySwitch = [[UISwitch alloc] init];
        [allDaySwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];

        allDaySwitch.on = [allDay boolValue];
        cell.accessoryView = allDaySwitch;
        cell.textLabel.text = @"All Day";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // we should disable selecting rows
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     this option should be activated when we have multiple dates on the same screen. In the case when we have just one date then we don't need to use it _currentDateIndex is zero by default ...
    _currentDateIndex= indexPath.row;
     */
}

-(void)dateChanged:(UIDatePicker*)picker {
    if (self.isTimePicker) {
        [_datesInfo setObject:[NSNumber numberWithInt:picker.countDownDuration] forKey:@"time"];

    } else {
        NSString *dateStr = [_dates objectAtIndex:_currentDateIndex];
        NSDate *date = picker.date;
        if (self.isSimpleDatePicker) {
            date = [date dateAsDateWithoutTime];
        }
        
        [_datesInfo setObject:date forKey:dateStr];
    }
    [self.tableView reloadData];
}

-(void)switchValueChanged:(UISwitch*)sender {
    [self.params setObject:[NSNumber numberWithBool:sender.on] forKey:@"allDay"];

    NSString *option = [_dates objectAtIndex:0];
    
    NSDate *date = [_datesInfo objectForKey:option];
    
    date = [date firstHourOfDay];

    if ([option isEqualToString:@"Start Date"]) {
    } else {
        date = [date dateByAddingTimeInterval:23*60*60 + 59*60];
    }

    [self.datePicker setDate:date animated:YES];
    [self dateChanged:self.datePicker];
}

- (NSString *) rcoDateToString: (NSDate *) aDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date_str =[dateFormat stringFromDate:aDate];
    
    
    return date_str;
}

- (NSString *) rcoDateAndTimeToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy HH:mm"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}

- (NSString *) rcoDateAndTimeToStringNoSeconds: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy HH:mm"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}


@end
