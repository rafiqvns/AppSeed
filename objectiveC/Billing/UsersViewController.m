//
//  UsersViewController.m
//  Billing2
//
//  Created by .D. Bodnar on 9/08/12.
//  Copyright 2012 RCO All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UsersViewController.h"
#import "DataRepository.h"
#import "TrainingDriverInstructorAggregate.h"
#import "TrainingDriverStudentAggregate.h"
#import "TrainingInstructor+CoreDataClass.h"
#import "TrainingStudent+CoreDataClass.h"
#import "CSDStudentViewController.h"
#import "UserAggregate.h"
#import "User_Imp.h"
#import "RCOValuesListViewController.h"
#import "Settings.h"
#import "TrainingCompany+CoreDataClass.h"
#import "RCOObjectListViewController.h"

#define Key_User @"user"
#define Key_UserItemType @"itemType"
#define Key_Company @"company"

#define TAG_GROUP_INPUT 100

@interface UsersViewController()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemsFiltered;
@property (nonatomic, strong) NSMutableDictionary *itemsIndexed;
@property (nonatomic, strong) NSMutableArray *indexes;

@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) UIBarButtonItem *filterBtn;
@property (nonatomic, strong) UIAlertController *al;

@property (nonatomic, assign) BOOL showFilterButton;
@property (nonatomic, assign) BOOL showCompanyFilterButton;
@property (nonatomic, strong) UIBarButtonItem *companyBtn;
@property (nonatomic, strong) TrainingCompany *trainingCompany;

@end

@implementation UsersViewController
@synthesize students, companies, instructors;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [self getScreenTitle];
    
#ifdef APP_CSD
    [self.addGroupBtn setEnabled:NO];
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commandLoaded" object:nil];
    
    
    
    if (!self.userItemType.length && !self.users.count) {
        self.showFilterButton = YES;
        NSString *prevUsersType = [Settings getSetting:USERS_PREV];
        if (prevUsersType.length) {
            self.userItemType = prevUsersType;
            self.title = [self getScreenTitle];
        }
    }
    
    
    
    if (DEVICE_IS_IPAD && self.groupName.length) {
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(closeButtonPressed:)];
        self.navigationItem.leftBarButtonItem = closeBtn;
    }
    
    if (self.showAddButton) {
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(addButtonPressed:)];
        self.navigationItem.rightBarButtonItem = addBtn;
        if (self.userItemType.length && self.trainingCompany.name.length) {
            [addBtn setEnabled:YES];
        } else {
            [addBtn setEnabled:NO];
        }
    }

    if (self.showFilterButton) {
        self.filterBtn = [[UIBarButtonItem alloc] initWithTitle:@"User Type"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(userTypeButtonPressed:)];
        if (self.userItemType.length) {
            //[self.filterBtn setTitle:[self.userItemType capitalizedString]];
        }
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
        [items insertObject:self.filterBtn atIndex:0];
        [self.bottomToolbar setItems:items];
    }
    
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];

    if ([organizationId isEqualToString:@"28"]) {
//         is CSD organization, we need to add some extra stuff there
        NSString *company = [Settings getSetting:CLIENT_COMPANY_NAME];
        if ([[company lowercaseString] containsString:@"certified safe driver"]) {
            self.showCompanyFilterButton = YES;
        }
    }
    
    if (self.showCompanyFilterButton) {
        self.companyBtn = [[UIBarButtonItem alloc] initWithTitle:@"Company"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(companyButtonPressed:)];
    }
    
    if (self.companyBtn) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
        if (self.filterBtn) {
            UIBarButtonItem *flexiBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
            [items insertObject:flexiBtn atIndex:0];
            [items insertObject:self.companyBtn atIndex:0];
        } else {
            [items insertObject:self.companyBtn atIndex:0];
        }
        [self.bottomToolbar setItems:items];
    }
    
    [self loadItems];
    
    if (self.groupName.length) {
        // we should enable removing users from Groups
        [self.tableView setEditing:YES];
        [self.tableView setAllowsSelectionDuringEditing:YES];
    }
    
    
    
}

-(NSString*)getScreenTitle {
    
    if (self.groupName.length) {
        return self.groupName;
    }
    
    if ([self.userItemType isEqualToString:kUserTypeStudent]) {
        return @"Students";
    } else if ([self.userItemType isEqualToString:kUserTypeInstructor]) {
        return @"Instructors";
    } else if ([self.userItemType isEqualToString:kUserTypeStaff]) {
        return @"Staff";
    } else if ([self.userItemType isEqualToString:kUserTypeTechnician]) {
        return @"Technicians";
    }  else if ([self.userItemType isEqualToString:kUserTypeLabor]) {
        return @"Labors";
    } else if ([self.userItemType isEqualToString:kUserTypeCustomer]) {
        return @"Customers";
    } else if ([self.userItemType isEqualToString:kUserTypeVendor]) {
        return @"Vendors";
    } else if ([self.userItemType isEqualToString:kUserTypeDealer]) {
        return @"Dealers";
    } else if ([self.userItemType isEqualToString:kUserTypeDriver]) {
        return @"Drivers";
    } else if ([self.userItemType isEqualToString:kUserTypeStaffManager]) {
        return @"Managers";
       }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self registerCallbacks];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unRegisterCallbacks];
}

-(void)registerCallbacks {
    [self.aggregate registerForCallback:self];
}

-(void)unRegisterCallbacks {
    [self.aggregate unRegisterForCallback:self];
}

- (void)companyButtonPressed:(UIBarButtonItem*)btn{
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    title = @"Companies";
    fields = [NSArray arrayWithObjects:@"name", @"number", nil];
    detailFields = nil;
    sortKey = @"name";
        
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:Key_Company
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = Key_Company;
    listController.title = title;
    listController.selectedItem = self.trainingCompany;
    
    
    NSLog(@"Company %@", self.trainingCompany);
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:btn];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

-(void)loadItems {
    
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"surname" ascending:YES];

        if (self.users.count) {
            // use the users that we passed
            self.items = [NSMutableArray arrayWithArray:[self.users sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
        } else {
            self.title = [self getScreenTitle];
            NSPredicate *finalPredicate = nil;
            NSArray *res = nil;

            if (self.showCompanyFilterButton) {
                if (self.trainingCompany) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"company=%@", self.trainingCompany.name];
                    res = [[self aggregate] getAllNarrowedBy:predicate andSortedBy:nil];
                } else {
                    //29.10.2019 we should force a filtering by company
                    res = nil;
                }
            } else {
                res = [[self aggregate] getAllNarrowedBy:finalPredicate andSortedBy:nil];
            }
            // 29.10.2019 Manager is ItemType:staff&UserType:manager
            if ([self.userItemType isEqualToString:kUserTypeStaffManager]) {
                NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userType=%@", kUserTypeStaffManager];
                res = [res filteredArrayUsingPredicate:userTypePredicate];
            }
            self.items = [NSMutableArray arrayWithArray:[res sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
        }
        
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];

        [self groupItems];
        
        [self.tableView reloadData];
        
    
    
    
}

-(void)groupItems {
    self.itemsIndexed = [NSMutableDictionary dictionary];
    self.indexes = [NSMutableArray array];

    for (RCOObject *obj in self.itemsFiltered) {
        NSString *lastName = [obj valueForKey:@"surname"];
        if (lastName.length == 0) {
            lastName = @" ";
        }
        char firstChar = [[lastName uppercaseString] characterAtIndex:0];
        NSString *key = [NSString stringWithFormat:@"%c", firstChar];
        NSMutableArray *arr = [self.itemsIndexed objectForKey:key];
        if (!arr) {
            arr = [NSMutableArray array];
        }
        
        [arr addObject:obj];
        
        [self.itemsIndexed setObject:arr forKey:key];
        if (![self.indexes containsObject:key]) {
            [self.indexes addObject:key];
        }
    }
}

-(IBAction)closeButtonPressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(IBAction)addButtonPressed:(id)sender {
    
    CSDStudentViewController *controller = [[CSDStudentViewController alloc] initWithNibName:@"CSDStudentViewController"
                                                                                              bundle:nil];
    controller.addDelegate = self;
    controller.addDelegateKey = Key_User;
    controller.userItemType = self.userItemType;
    controller.company = self.trainingCompany;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [NSString stringWithFormat:@"Remove user from group?"];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ////[tableView beginUpdates];
         
        id itemToDelete = nil;
         
        itemToDelete = [self.itemsFiltered objectAtIndex:indexPath.row];
         
        [self removeUserFromGroup:itemToDelete];
        
        //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
         
        ///[tableView endUpdates];
        [tableView reloadData];
         NSLog(@"");
    }
}

-(void)removeUserFromGroup:(id) item{
    [self.itemsFiltered removeObject:item];
    [self.items removeObject:item];
    [self groupItems];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.indexes objectAtIndex:section];
    NSArray *arr = [self.itemsIndexed objectForKey:key];
    return [arr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.indexes.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [self.indexes objectAtIndex:section];
    return key;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserCell"];
    }

    NSString *key = [self.indexes objectAtIndex:indexPath.section];
    NSArray *arr = [self.itemsIndexed objectForKey:key];
    
    
    if ([[Settings getSetting:WorkOffline] isEqualToString:@"no"]) {
        NSDictionary *obj = [arr objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [obj valueForKey:@"first_name"],  [obj valueForKey:@"last_name"]];
        
        NSDictionary *info = [obj valueForKey:@"info"];
        
        if ([HelperSharedManager isCheckNotNULL:info]) {
            
            NSString *drivingLicenseNum = [info valueForKey:@"driver_license_number"];
            NSString *drivingLicenseExpiry = [info valueForKey:@"driver_license_expire_date"];
            
            NSString *drivingLicenseClass= [info valueForKey:@"driver_license_class"];
            
            
            NSString *drivingLNum = @"";
            NSString *drivingExpDate = @"";
            NSString *drivingClass = @"";
            if ([HelperSharedManager isCheckNotNULL:drivingLicenseNum]) {
                drivingLNum = drivingLicenseNum;
            }
            
            if ([HelperSharedManager isCheckNotNULL:drivingLicenseExpiry]) {
                drivingExpDate = drivingLicenseExpiry;
            }
            
            if ([HelperSharedManager isCheckNotNULL:drivingLicenseClass]) {
                drivingClass = drivingLicenseClass;
            }
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"License Nr:%@, Exp:%@ (%@)", drivingLNum, drivingExpDate, drivingClass];
            
        }
        
        
    } else {
        User *obj = [arr objectAtIndex:indexPath.row];
        cell.textLabel.text = [self getUserTextDescription:obj];
        cell.detailTextLabel.text = [self getUserTextDetailDescription:obj];
    }
    
    
    /*
    if ([self isStudentList] || self.groupName.length) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
     */
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(NSString*)getUserTextDescription:(User*)user {
    
    
    
    NSString *info = [user Name];
    
    return [NSString stringWithFormat:@"%@", info];
}

-(NSString*)getUserTextDetailDescription:(User*)user {
    if ([self isStudentList]) {
        User *student = (User*)user;
        NSString *dateStr = @"";
        
        if (student.driverLicenseExpirationDate) {
            dateStr = [[self aggregate] rcoDateToString:student.driverLicenseExpirationDate];
        }
        
        return [NSString stringWithFormat:@"License Nr:%@, Exp:%@ (%@)", student.driverLicenseNumber, dateStr, [student driverLicenseClass]];
    } else {
        return [user employeeNumber];
    }
}

-(BOOL)isStudentList {
    return [self.userItemType isEqualToString:kUserTypeStudent] ? YES : NO;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexes;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.indexes objectAtIndex:index];
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    return indexPath;

    if ([self isStudentList] || self.groupName.length) {
        return indexPath;
    } else {
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *key = [self.indexes objectAtIndex:indexPath.section];
    NSArray *arr = [self.itemsIndexed objectForKey:key];
    User *obj = [arr objectAtIndex:indexPath.row];
    
    

    CSDStudentViewController *controller = [[CSDStudentViewController alloc] initWithNibName:@"CSDStudentViewController"
                                                                                      bundle:nil];
    controller.addDelegate = self;
    controller.addDelegateKey = Key_User;
    controller.user = obj;
    controller.userItemType = obj.itemType;

    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark -
#pragma mark Button Actions

- (IBAction)addGroupButtonPressed:(id)sender {
    
    self.al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Group Name", nil)
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;

    [self.al addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"name";
        textField.text = nil;
        if (@available(iOS 13,*)) {
        textField.textColor = [UIColor labelColor];
        } else {
        textField.textColor = [UIColor darkTextColor];
        }
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [textField addTarget:weakSelf action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];

    }];
    
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           UITextField *input = self.al.textFields[0];
                                                           [self addGroup:input.text];
                                                       }];
    [saveAction setEnabled:NO];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [self.al addAction:saveAction];
    [self.al addAction:cancelAction];
    [self presentViewController:self.al animated:YES completion:nil];
}

-(void)addGroup:(NSString*)grpupName {
    
    self.progressHUD.labelText = @"Creating group...";
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];

    UserAggregate *agg = (UserAggregate*)[self aggregate];
    if (!agg) {
        agg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
        [agg registerForCallback:self];
    }
    NSString *company = [Settings getSetting:CLIENT_COMPANY_NAME];
    
    [agg createNewUserGroup:grpupName forCompany:company];
}

- (IBAction)addItem:(id)sender {
    
}

-(IBAction)userTypeButtonPressed:(UIBarButtonItem*)fromBtn {
    NSArray *values = [NSArray arrayWithObjects:kUserTypeStaff, kUserTypeStaffManager, kUserTypeTechnician, kUserTypeLabor, kUserTypeCustomer, kUserTypeInstructor, kUserTypeStudent, kUserTypeVendor, kUserTypeDealer, kUserTypeDriver, nil];
    
#ifdef APP_CSD
    values = [NSArray arrayWithObjects:kUserTypeInstructor, kUserTypeStudent, nil];
#endif
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:values
                                                                                                forKey:Key_UserItemType];
    listController.selectDelegate = self;
    listController.title = @"User Types";
    listController.showIndex = NO;
    listController.newLogic = YES;
    if (self.userItemType.length) {
        listController.selectedValue = self.userItemType;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:fromBtn];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

#pragma mark -
#pragma mark RCODataViewController

- (Aggregate *) aggregate {
    if (self.userItemType.length) {
        if ([self.userItemType isEqualToString:kUserTypeStaffManager]) {
            return [[DataRepository sharedInstance] getAggregateForClass:kUserTypeStaff];
        }
        return [[DataRepository sharedInstance] getAggregateForClass:self.userItemType];
    } else {
        return nil;
    }
}

#pragma mark ----

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    
    if ([message isEqualToString:CREATE_USER_GROUP]) {
        NSLog(@"");
        
        id resp = [messageInfo objectForKey:RESPONSE_OBJ];
        
        if ([resp isKindOfClass:[NSDictionary class]]) {
            NSDictionary *respDict = (NSDictionary*)resp;
            NSString *name = [respDict objectForKey:@"name"];
            NSString *msg = [NSString stringWithFormat:@"Group:\n%@\n sucessfully created!", name];
            [self showMessage:msg];
        }
        
        [aggregate unRegisterForCallback:self];
    }
    [self.progressHUD hide:YES];
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];

    if ([message isEqualToString:CREATE_USER_GROUP]) {
        NSLog(@"");
        [self showSimpleMessage:@"Failed to craete user group!"];
        
        [aggregate unRegisterForCallback:self];
    }
    [self.progressHUD hide:YES];

}



#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    
    if ([key isEqualToString:Key_UserItemType] && object) {
        self.userItemType = (NSString*)object;
        if (self.userItemType.length) {
            //[self.filterBtn setTitle:[self.userItemType capitalizedString]];
            [Settings setSetting:self.userItemType forKey:USERS_PREV];
            [Settings save];
            if (self.trainingCompany.name.length) {
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
            }
        }
    } else if ([key isEqualToString:Key_Company]) {
        if ([object isKindOfClass:[TrainingCompany class]]) {
            self.trainingCompany = (TrainingCompany*)object;
            [self.companyBtn setTitle:self.trainingCompany.name];
        }
        if (self.trainingCompany.name.length) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }
    }
    
    if (object) {
        [self loadItems];
    }
    
    [self.tableView reloadData];

    if (DEVICE_IS_IPHONE) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark UISearchBarDelegate Methods

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    self.filterPredicate = nil;
    [self groupItems];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length]) {
        // 23.03.2020 we should split the text by space
        NSMutableArray *predicates = [NSMutableArray array];
        NSArray *words = [searchText componentsSeparatedByString:@" "];
        
        for (NSString *word in words) {
            NSString *workdKey = [NSString stringWithString:word];
            workdKey = [workdKey stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if (!word.length) {
                continue;
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rcoObjectSearchString contains[cd] %@", word];
            [predicates addObject:predicate];
        }
        
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        
        //NSArray *arr = [self.items filteredArrayUsingPredicate:predicate];
        NSArray *arr = [self.items filteredArrayUsingPredicate:finalPredicate];
        self.itemsFiltered = [NSMutableArray arrayWithArray:arr];
        //self.filterPredicate = predicate;
        self.filterPredicate = finalPredicate;
    } else {
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
        self.filterPredicate = nil;
    }
    
    [self groupItems];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UItextFieldDelegate Methods

- (IBAction)textFieldChanged:(UITextField*) textField {
    NSArray *actions = self.al.actions;
    UIAlertAction *sendAction = [actions objectAtIndex:0];
    
    if ([textField.text length] > 3) {
        // we should enable send button
        [sendAction setEnabled:YES];
    } else {
        [sendAction setEnabled:NO];
    }
}




@end
