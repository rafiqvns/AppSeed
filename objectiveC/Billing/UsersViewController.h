//
//  UsersViewController.h
//  Billing2
//
//  Created by .D. Bodnar on 9/08/12.
//  Copyright 2012 RCO All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"
#import "ServerManager.h"
#import "HelperUtility.h"

@interface UsersViewController : HomeBaseViewController <AddObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverControllerDelegate, UITextFieldDelegate> {
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSString *userItemType;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) BOOL showAddButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addGroupBtn;

@property (nonatomic, strong) NSArray *students;
@property (nonatomic, strong) NSArray *companies;
@property (nonatomic, strong) NSArray *instructors;

- (IBAction)addItem:(id)sender;
- (IBAction)addGroupButtonPressed:(id)sender;


@end
