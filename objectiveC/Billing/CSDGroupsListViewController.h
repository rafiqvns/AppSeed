//
//  UserGroupsListMembersViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 7/03/19.
//  Copyright (c) 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@interface CSDGroupsListViewController : HomeBaseViewController <AddObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate> {
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *groupInfo;
@property (nonatomic, assign) BOOL isUserGroup;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *addMemberBtn;

-(IBAction)reloadButtonPressed:(id)sender;
-(IBAction)addMemberButtonPressed:(id)sender;

@end
