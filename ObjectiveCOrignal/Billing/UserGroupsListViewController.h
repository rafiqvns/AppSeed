//
//  UserGroupsListViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 7/03/19.
//  Copyright (c) 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@interface UserGroupsListViewController : HomeBaseViewController <AddObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate> {
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isUserGroups;
@property (nonatomic, assign) BOOL isSelectMode;
@property (nonatomic, strong) NSArray *userGroups;
@property (nonatomic, strong) NSString *selectedGroupRecordId;
@property (nonatomic, strong) NSString *company;

-(IBAction)reloadButtonPressed:(id)sender;
-(IBAction)addGroupButtonPressed:(id)sender;

@end
