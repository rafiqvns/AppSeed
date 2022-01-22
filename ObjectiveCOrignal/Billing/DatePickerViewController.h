//
//  DatePickerViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 12/28/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateSelectionProtocol.h"

@interface DatePickerViewController : UIViewController {
    UIDatePickerMode _datePickerMode;
    NSInteger _option;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil datePickerMode:(UIDatePickerMode)datePickerMode forOption:(NSInteger)option;

- (IBAction)dateChanged:(id)sender;

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) id<DateSelectionProtocol> selectionDateDelegate;
@end
