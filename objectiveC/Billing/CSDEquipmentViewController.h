//
//  CSDEquipmentViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"
#import "CSDTestSelectObject.h"

@interface CSDEquipmentViewController : HomeBaseViewController <AddObject, UITextFieldDelegate, CSDSelectObject> {
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *prevBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *nextBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *countBtn;
@property (nonatomic, assign) BOOL addParentMobileRecordId;


-(IBAction)deleteButtonPressed:(id)sender;
-(IBAction)viewChanged:(id)sender;
-(IBAction)addButtonPressed:(id)sender;
-(IBAction)prevButtonPressed:(id)sender;
-(IBAction)nextButtonPressed:(id)sender;
-(IBAction)infoButtonPressed:(id)sender;

@end
