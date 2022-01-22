//
//  CSDFormsDetailListViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/12/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@class TestDataHeader;

@interface CSDFormsDetailListViewController : HomeBaseViewController <AddObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
}

@property (nonatomic, weak) id<RCOSpliterSelectionDelegate> selectionDelegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TestDataHeader *header;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *verifyBtn;
@property (nonatomic, strong) NSString *formNumber;

-(IBAction)addButtonPressed:(id)sender;
-(IBAction)verifyButtonPressed:(id)sender;
-(IBAction)actionButtonPressed:(id)sender;
-(IBAction)filterButtonPressed:(id)sender;

@end
