//
//  DatePickerViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 12/28/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()

@end

@implementation DatePickerViewController

@synthesize selectionDateDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil datePickerMode:(UIDatePickerMode)datePickerMode forOption:(NSInteger)option
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _datePickerMode = datePickerMode;
        _option = option;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.datePicker.datePickerMode = _datePickerMode;
}

- (IBAction)dateChanged:(id)sender {
    
    if ([self.selectionDateDelegate respondsToSelector:@selector(dateSelected:forOption:)]) {
        [self.selectionDateDelegate dateSelected:self.datePicker.date forOption:_option];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
