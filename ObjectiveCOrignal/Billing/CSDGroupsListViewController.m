//
//  CSDGroupsListViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 7/03/19.
//  Copyright (c) 2019 RCO. All rights reserved.
//

#import "CSDGroupsListViewController.h"
#import "DataRepository.h"
#import "NSDate+Misc.h"
#import "NSDate+Helpers.h"
#import "UserAggregate.h"
#import "User_Imp.h"
#import "UsersViewController.h"
#import "UserGroupsListViewController.h"

#define TAG_ADD_Group 10

#define KeyAddFunctionalGroupMember @"addFunctionalGroupMember"

@interface CSDGroupsListViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemsFiltered;

@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSString *selectedGroup;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIAlertController *al;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) NSMutableArray *usersToRemove;
@property (nonatomic, strong) UIBarButtonItem *editBtn;
@property (nonatomic, strong) UIBarButtonItem *reloadBtn;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;

@end

@implementation CSDGroupsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [self.groupInfo objectForKey:@"ObjectName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commandLoaded" object:nil];
    if (self.isUserGroup) {
        UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                 target:self
                                                                                 action:@selector(saveButtonPressed:)];
        [saveBtn setEnabled:NO];
        self.navigationItem.rightBarButtonItem = saveBtn;
        [self.bottomToolbar setItems:[NSArray array]];
        self.selectedUsers = [NSMutableArray array];
    } else {
        self.reloadBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                       target:self
                                                                       action:@selector(reloadButtonPressed:)];
        
        self.editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                     target:self
                                                                     action:@selector(editButtonPressed:)];
        self.doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                     target:self
                                                                     action:@selector(doneButtonPressed:)];

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editBtn, self.reloadBtn, nil];
        self.usersToRemove = [NSMutableArray array];
    }
    [self reloadButtonPressed:nil];
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
}

-(void)getGroupMembers {
    
    self.progressHUD.labelText = @"Please wait while getting Members...";
    
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    [self performSelector:@selector(_getGroupMembers) withObject:nil afterDelay:0.1];
}

-(void)_getGroupMembers {
    
    UserAggregate *usrAgg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    [usrAgg registerForCallback:self];
    NSString *groupName = [self.groupInfo objectForKey:@"ObjectName"];
    if (self.isUserGroup) {
        [usrAgg getUserGroupMembers:groupName];
    } else {
        [usrAgg getFunctionalGroupMembers:groupName];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Actions

-(IBAction)saveButtonPressed:(id)sender {
    NSLog(@"");
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:[self.selectedUsers objectAtIndex:0] forKey:self.addDelegateKey];
    }
}
-(IBAction)editButtonPressed:(id)sender {
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.doneBtn, self.reloadBtn, nil];
    [self.tableView setEditing:YES];
    [self.addMemberBtn setEnabled:NO];
    [self.reloadBtn setEnabled:NO];
}

-(IBAction)doneButtonPressed:(id)sender {
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editBtn, self.reloadBtn, nil];
    [self.addMemberBtn setEnabled:YES];
    [self.reloadBtn setEnabled:YES];
    [self.tableView setEditing:NO];
    // Remove users from list
    NSLog(@"");
    UserAggregate *usrAgg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    for (NSDictionary *userDict in self.usersToRemove) {
        NSLog(@"");
        NSString *funcGroupName = [userDict objectForKey:@"funcGroupName"];
        NSString *userRecordId = [userDict objectForKey:@"userRecordId"];
        [usrAgg deleteUser:userRecordId fromFunctionalGroup:funcGroupName];
    }
    [self.tableView reloadData];
}

-(IBAction)reloadButtonPressed:(id)sender {
    self.items = [NSMutableArray array];
    self.itemsFiltered = [NSMutableArray array];
    self.search.text = nil;
    [self.view endEditing:YES];
    [self.tableView reloadData];
    [self getGroupMembers];
}

-(IBAction)addMemberButtonPressed:(id)sender {
    UserAggregate *usrAgg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    [usrAgg registerForCallback:self];
    [usrAgg getUserGroupsForCompany:nil];
}

-(IBAction)actionButtonPressed:(id)sender {
    return;
}

#pragma mark UITableViewDataSource

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove user from group?";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        NSDictionary *dict = [self.items objectAtIndex:indexPath.row];
        [self.usersToRemove addObject:dict];
        [self.items removeObject:dict];
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
    }
}

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
    
    NSDictionary *memberInfo = [self.itemsFiltered objectAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[UIColor darkTextColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkTextColor]];

    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@ %@", (int)(indexPath.row +1), [memberInfo objectForKey:@"userFirstName"], [memberInfo objectForKey:@"userLastName"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [memberInfo objectForKey:@"userRecordId"]];

    if ([self.selectedUsers containsObject:memberInfo]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

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
    NSString *desc = [NSString stringWithFormat:@"%@", [recordInfo objectForKey:@"RecordId"]];
    return desc;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self.itemsFiltered objectAtIndex:indexPath.row];

    if (self.isUserGroup) {
        if ([self.selectedUsers containsObject:dict]) {
            self.selectedUsers = [NSMutableArray array];
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        } else {
            self.selectedUsers = [NSMutableArray arrayWithObject:dict];
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }
        [self.tableView reloadData];
        return;
    }
    
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
    if ([key isEqualToString:KeyAddFunctionalGroupMember]) {
        NSLog(@"");
        
        if (DEVICE_IS_IPAD) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:NO];
        }
        NSLog(@"");
        if ([object isKindOfClass:[NSDictionary class]]) {
            [self addMemberToCurrentFunctionalGroup:(NSDictionary*)object];
        }
    }
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.tableView reloadData];
}

-(void)addMemberToCurrentFunctionalGroup:(NSDictionary*)memberInfo {
    NSString *userRecordId = [memberInfo objectForKey:@"userRecordId"];
    if (!userRecordId.length) {
        return;
    }
    NSString *functionalGroupName = [self.groupInfo objectForKey:@"ObjectName"];
    if (!functionalGroupName.length) {
        return;
    }
    
    [self.items addObject:memberInfo];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"userLastName" ascending:YES];
    
    [self.items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    [self.tableView reloadData];

    UserAggregate *usrAgg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    [usrAgg registerForCallback:self];
    [usrAgg addUser:userRecordId toFunctionalGroup:functionalGroupName];
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

-(void)showUserGroupPickerFor:(NSArray*)groups {
    UserGroupsListViewController *controller = [[UserGroupsListViewController alloc] initWithNibName:@"UserGroupsListViewController" bundle:nil];
    controller.isUserGroups = YES;
    controller.userGroups = groups;
    
    controller.addDelegateKey = KeyAddFunctionalGroupMember;
    controller.addDelegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark ----

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];

    if ([message isEqualToString:ADD_USER_TO_FUNCTIONAL_GROUP]) {
        NSString *msg = @"Successfully added member";
        [self showSimpleMessage:msg];
        
        [aggregate unRegisterForCallback:self];
        [self.progressHUD hide:YES];
        [self.tableView reloadData];
    } else if ([message isEqualToString:GET_USER_GROUP_MEMBERS]) {
        NSLog(@"");
        NSMutableArray *members = [NSMutableArray array];
        NSArray *values = [messageInfo objectForKey:RESPONSE_OBJ];
        
        if (values.count > 0) {
            for (NSDictionary *dict in values) {
                NSMutableDictionary *mapCodingInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
                [mapCodingInfo addEntriesFromDictionary:[dict objectForKey:@"mapCodingInfo"]];
                if (mapCodingInfo) {
                    [members addObject:mapCodingInfo];
                }
            }
        }
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"ObjectName" ascending:YES];
        [members sortUsingDescriptors:[NSArray arrayWithObject:sd]];

        self.items = [NSMutableArray arrayWithArray:members];
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
        
        [aggregate unRegisterForCallback:self];
        [self.progressHUD hide:YES];
        [self.tableView reloadData];
    } else  if ([message isEqualToString:GET_FUNCTIONAL_GROUP_MEMBERS]) {
        NSLog(@"");
        
        NSArray *members = [messageInfo objectForKey:RESPONSE_OBJ];
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"userLastName" ascending:YES];
        self.items = [NSMutableArray arrayWithArray:[members sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
        
        [aggregate unRegisterForCallback:self];
        [self.progressHUD hide:YES];
        [self.tableView reloadData];
        
    } else if ([message isEqualToString:RD_G_R_U_X_F]) {
        NSString *objId = [messageInfo objectForKey:@"objId"];
        if ([objId isEqualToString:UserGroupRecords]) {
            
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
            
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"ObjectName" ascending:YES];
            [groups sortUsingDescriptors:[NSArray arrayWithObject:sd]];
            
            [aggregate unRegisterForCallback:self];
            [self.progressHUD hide:YES];
            [self showUserGroupPickerFor:groups];
        }
        [self.progressHUD hide:YES];
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:ADD_USER_TO_FUNCTIONAL_GROUP]) {
        NSString *msg = @"Failed to add member to functional group";
        [self showSimpleMessage:msg];
        [aggregate unRegisterForCallback:self];
    } else if ([message isEqualToString:GET_FUNCTIONAL_GROUP_MEMBERS]) {
        NSLog(@"");
        NSString *msg = @"Failed to get functional group members for current group";
        [self showSimpleMessage:msg];
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

@end
