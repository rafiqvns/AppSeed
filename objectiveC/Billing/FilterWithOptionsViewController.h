//
//  FilterWithOptionsViewController.h
//  MobileOffice
//
//  Created by Dragos Dragos on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@interface FilterWithOptionsViewController : HomeBaseViewController <AddObject, UITextFieldDelegate> {
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *selectedDate;
@property (nonatomic, strong) NSDate *customDate;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSArray *optionsSelected;
@property (nonatomic, assign) BOOL hideDateOptions;
@property (nonatomic, assign) BOOL enableSave;

@end
