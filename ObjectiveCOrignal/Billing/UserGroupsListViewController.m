//
//  UserGroupsListViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 7/03/19.
//  Copyright (c) 2019 RCO. All rights reserved.
//

#import "UserGroupsListViewController.h"
#import "DataRepository.h"
#import "NSDate+Misc.h"
#import "NSDate+Helpers.h"
#import "UserAggregate.h"
#import "User_Imp.h"
#import "UsersViewController.h"
#import "UserGroupsListMembersViewController.h"

#define TAG_ADD_Group 10

@interface UserGroupsListViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemsFiltered;

@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSString *selectedGroup;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIAlertController *al;

@end

@implementation UserGroupsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commandLoaded" object:nil];
    
    if (!self.isUserGroups) {
        self.title = @"Functional Groups";
        UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                      target:self
                                                                                      action:@selector(reloadButtonPressed:)];
        self.navigationItem.rightBarButtonItem = reloadButton;
        [self reloadButtonPressed:nil];
    } else {
        self.title = @"User Groups";
        self.items = [NSMutableArray arrayWithArray:self.userGroups];
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(backButtonPressed:)];
        self.navigationItem.leftBarButtonItem = backBtn;
    }
    if (self.isSelectMode) {
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(closeButtonPressed:)];
        self.navigationItem.leftBarButtonItem = closeBtn;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self aggregate] registerForCallback:self];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self aggregate] unRegisterForCallback:self];
    [[[DataRepository sharedInstance] getUserAggregateAvailablePlus] unRegisterForCallback:self];
}

-(void)getFunctionalGroups {
    self.progressHUD.labelText = @"Please wait while getting Groups...";
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    [self performSelector:@selector(_getFunctionalGroups) withObject:nil afterDelay:0.1];
}

-(void)_getFunctionalGroups {
    UserAggregate *usrAgg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    [usrAgg registerForCallback:self];
    [usrAgg getFunctionalGroupsforCompany:self.company];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)closeButtonPressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(IBAction)reloadButtonPressed:(id)sender {
    self.items = [NSMutableArray array];
    self.itemsFiltered = [NSMutableArray array];
    self.search.text = nil;
    [self.view endEditing:YES];
    [self.tableView reloadData];
    [self getFunctionalGroups];
}

-(IBAction)addGroupButtonPressed:(id)sender {
    if (self.isUserGroups) {
        [self showSimpleMessage:@"not implemented for user groups"];
        return;
    }
    
    
    self.al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Group Name", nil)
                                                  message:nil
                                           preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;

    [self.al addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = nil;

        if (@available(iOS 13,*)) {
        textField.textColor = [UIColor labelColor];
        } else {
        textField.textColor = [UIColor darkTextColor];
        }
        
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.tag = TAG_ADD_Group;
        [textField addTarget:weakSelf action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        textField.delegate = weakSelf;
    }];
    
    UIAlertAction* addAction = [UIAlertAction actionWithTitle:@"Add"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          UITextField *input = self.al.textFields[0];
                                                          NSString *name = input.text;
                                                          [self addGroup:name];
                                                      }];
    
    [addAction setEnabled:NO];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    
    [self.al addAction:addAction];
    [self.al addAction:cancelAction];
    [self presentViewController:self.al animated:YES completion:nil];
}


-(void)addGroup:(NSString*)groupName {
    NSArray *res = [self getGroupWithName:groupName];
    
    NSArray *specialChars = @[@"\\", @"/", @"#"];
    
    for (NSString *c in specialChars) {
        if ([groupName containsString:c]) {
            NSString *msg = [NSString stringWithFormat:@"Character:\n%@\n is not allowed!", c];
            [self showSimpleMessage:msg];
            return;
        }
    }
    
    
    if (res.count) {
        NSString *message = [NSString stringWithFormat:@"Functional Group with name:\n%@\n already exists.\nPlease enter a new name!", groupName];
        [self showSimpleMessage:message andTitle:@"Error"];
    } else {
        UserAggregate *agg = (UserAggregate*)[self aggregate];
        [agg registerForCallback:self];
        [agg createFunctionalGroup:groupName forCompany:self.company];
    }
}

-(NSArray*)getGroupWithName:(NSString*)groupName {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ObjectName.lowercaseString=%@", groupName.lowercaseString];
    NSArray *res = [self.items filteredArrayUsingPredicate:predicate];
    return res;
}

-(IBAction)actionButtonPressed:(id)sender {
    return;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemsFiltered count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"userGroupCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"userGroupCell"];
    }
    
    NSDictionary *groupInfo = [self.itemsFiltered objectAtIndex:indexPath.row];
    if (@available(iOS 13,*)) {
        [cell.textLabel setTextColor:[UIColor labelColor]];
        [cell.detailTextLabel setTextColor:[UIColor labelColor]];
    } else {
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
        [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", (int)(indexPath.row +1), [self getFunctionalGroupDescription:groupInfo]];
    cell.detailTextLabel.text = [self getFunctionalGroupDetailDescription:groupInfo];

    NSString *recordId = [groupInfo objectForKey:@"RecordId"];
    if ([self.selectedGroupRecordId isEqualToString:recordId]) {
        cell.imageView.image = [UIImage imageNamed:@"check.png"];
    } else {
        cell.imageView.image = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}


-(NSString*)getFunctionalGroupDescription:(NSDictionary*)recordInfo {
    NSString *desc = [NSString stringWithFormat:@"%@", [recordInfo objectForKey:@"ObjectName"]];
    return desc;
}

-(NSString*)getFunctionalGroupDetailDescription:(NSDictionary*)recordInfo {
    NSString *desc = [recordInfo objectForKey:@"RecordId"];
    return desc;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *groupInfo = [self.itemsFiltered objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self showGroupMembersforGroup:groupInfo fromView:cell];
    
    return;
    
    
    NSDictionary *dict = [self.itemsFiltered objectAtIndex:indexPath.row];
    UserAggregate *agg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    [agg registerForCallback:self];
    
    self.selectedGroup = [dict objectForKey:@"ObjectName"];
    self.selectedIndexPath = indexPath;

    /*
     08.08.2019
    NSString *objectType = [dict objectForKey:@"objectType"];
    NSString *objectId = [NSString stringWithFormat:@"%@", [dict objectForKey:@"LobjectId"]];
    [agg getChildrenDirectoryIdsForGroupId:objectId andType:objectType];
     */
    [agg getFunctionalGroupMembers:self.selectedGroup];
    return;
    
    NSString *name = [dict objectForKey:@"ObjectName"];
    NSArray *users = [self getUsersForGroup:name forIndexPath:indexPath];
    
    if (!users.count) {
        [self showSimpleMessage:[NSString stringWithFormat:@"No users found for group:\n%@", name]];
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self showUsers:users forGroup:name fromView:cell];
    }
}

-(void)showGroupMembersforGroup:(NSDictionary*)groupInfo fromView:(UIView*)fromView {
    UserGroupsListMembersViewController *controller = [[UserGroupsListMembersViewController alloc] initWithNibName:@"UserGroupsListMembersViewController" bundle:nil];
    controller.groupInfo = groupInfo;
    controller.isUserGroup = self.isUserGroups;
    
    // when we are adding functional groups ....
    controller.addDelegateKey = self.addDelegateKey;
    controller.addDelegate = self.addDelegate;
    controller.isSelectionMode = YES;
    controller.company = self.company;
    
    if (self.isUserGroups) {
        //we should enable selection
        controller.allowMultipleSelection = YES;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:controller fromView:fromView];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(NSArray*)getUsersForGroup:(NSString*)groupName forIndexPath:(NSIndexPath*)indexPath{
    UserAggregate *agg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    NSArray *users = [agg getObjectsFromFunctionalGroupWithName:groupName andNumber:nil];
    NSLog(@"users = %@", users);
    NSLog(@"users =");
    
    return users;
}

-(void)showUsers:(NSArray*)users forGroup:(NSString*)groupName fromView:(UIView*)fromView {
    UsersViewController *controller = [[UsersViewController alloc] initWithNibName:@"UsersViewController" bundle:nil];
    controller.users = users;
    controller.groupName = [NSString stringWithFormat:@"%@(%d)", groupName, (int)users.count];
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:controller fromView:fromView];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
}

-(void)deleteSelectedItem {

}

-(Aggregate*)aggregate {
    UserAggregate *usrAgg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];

    return usrAgg;
}

- (void)objectSyncComplete: (Aggregate *) fromAggregate {
    [self.tableView reloadData];
}

#pragma mark AddObject Methods

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.tableView reloadData];
}

-(void)didAddObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    [self.tableView reloadData];
}

-(void)loadUsersWithIds:(NSArray*)ids {
    
    UserAggregate *usrAgg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    NSArray *users = [usrAgg getAllUsersWithIds:ids];

    UsersViewController *controller = [[UsersViewController alloc] initWithNibName:@"UsersViewController" bundle:nil];
    controller.users = users;
    controller.groupName = [NSString stringWithFormat:@"%@(%d)", self.selectedGroup, (int)users.count];
    if (DEVICE_IS_IPAD) {
        UITableViewCell *fromView = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        [self showPopoverForViewController:controller fromView:fromView];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
}

#pragma mark ----

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];

    if ([message isEqualToString:CREATE_FUNCTIONAL_GROUP]) {
        NSString *objId = [messageInfo objectForKey:@"objId"];
        NSString *message = [NSString stringWithFormat:@"Group:\n%@\n sucessfully created!", objId];
        
        [self showSimpleMessage:message];
        [self reloadButtonPressed:nil];
        [aggregate unRegisterForCallback:self];
        NSLog(@"");
    } else if ([message isEqualToString:GET_FUNCTIONAL_GROUP_MEMBERS]) {
        NSLog(@"");
        [aggregate unRegisterForCallback:self];
    } else if ([message isEqualToString:RD_G_R_U_X_F]) {
        NSString *objId = [messageInfo objectForKey:@"objId"];
        
        if ([objId isEqualToString:UserFunctionalGroupRecords]) {
            
            NSMutableArray *groups = [NSMutableArray array];
            
            NSArray *values = [messageInfo objectForKey:RESPONSE_OBJ];
            if (values.count > 0) {
                for (NSDictionary *dict in values) {
                    NSMutableDictionary *mapCodingInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [mapCodingInfo addEntriesFromDictionary:[dict objectForKey:@"mapCodingInfo"]];
                    
                    if (mapCodingInfo) {
                        [groups addObject:mapCodingInfo];
                    }
                }
            }
            //NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"Active.boolValue = yes"];
            
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"ObjectName" ascending:YES];
            [groups sortUsingDescriptors:[NSArray arrayWithObject:sd]];
            
            self.items = [NSMutableArray arrayWithArray:groups];

            self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
            [self.tableView reloadData];
            NSLog(@"");
        }
        [aggregate unRegisterForCallback:self];
        [self.progressHUD hide:YES];
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:CREATE_FUNCTIONAL_GROUP]) {
        NSLog(@"");
        NSString *objId = [messageInfo objectForKey:@"objId"];
        NSString *message = [NSString stringWithFormat:@"Failed to create Function group:\n\n%@", objId];
        
        [self showSimpleMessage:message];
        [aggregate unRegisterForCallback:self];
    }
    [self.progressHUD hide:YES];
}

#pragma mark UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText length]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Name contains[cd] %@", searchText];
        self.itemsFiltered = [NSMutableArray arrayWithArray:[self.items filteredArrayUsingPredicate:predicate]];
    } else {
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    [self.tableView reloadData];
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UItextFieldDelegate Methods

- (IBAction)textFieldChanged:(UITextField*) textField {
    if (textField.tag == TAG_ADD_Group) {
        NSArray *actions = self.al.actions;
        UIAlertAction *addAction = [actions objectAtIndex:0];
        if (textField.text.length > 2) {
            // we should enable Add button
            [addAction setEnabled:YES];
        } else {
            [addAction setEnabled:NO];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == TAG_ADD_Group) {
        NSArray *specialChars = @[@"\\", @"/", @"#"];
        NSInteger index = [specialChars indexOfObject:string];
        if (index != NSNotFound) {
            [self showSimpleMessage:@"xxx"];
            return NO;
        }
        return YES;
    } else {
        return YES;
    }
}

@end
