//
//  UsersViewController.h
//  Billing2
//
//  Created by .D. Bodnar on 9/08/12.
//  Copyright 2012 RCO All rights reserved.
//

#import "HomeBaseViewController.h"
#import "TrainingCompanyAggregate.h"
#import "AddObject.h"

@interface UsersViewController : HomeBaseViewController <AddObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverControllerDelegate, UITextFieldDelegate> {
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSString *userItemType;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) BOOL showAddButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addGroupBtn;


- (IBAction)addItem:(id)sender;
- (IBAction)addGroupButtonPressed:(id)sender;


@end
