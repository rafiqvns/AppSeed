//
//  CSDSimpleFormViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@interface CSDSimpleFormViewController : HomeBaseViewController <AddObject, UITextFieldDelegate> {
    
}
@property (nonatomic, strong) RCOObject *form;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *prevBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *nextBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *countBtn;


-(IBAction)deleteButtonPressed:(id)sender;
-(IBAction)viewChanged:(id)sender;
-(IBAction)addButtonPressed:(id)sender;
-(IBAction)infoButtonPressed:(id)sender;

@end
