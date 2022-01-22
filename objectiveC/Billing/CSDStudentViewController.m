//
//  CSDStudentViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDStudentViewController.h"
#import "InputCell.h"
#import "DateSelectorViewController.h"
#import "DataRepository.h"
#import "RCOObjectListViewController.h"
#import "RCOValuesListViewController.h"
#import "NSDate+TKCategory.h"
#import "TrainingStudent+CoreDataClass.h"
#import "TrainingDriverStudentAggregate.h"
#import "TrainingCompany+CoreDataClass.h"

#define Key_Class @"driverLicenseClass"
#define Key_State @"driverLicenseState"
#define Key_Company @"company"
//#define Key_Company_Id @"company"
#define Key_UserGroup @"userGroupName"

#define TAG_GROUP_INPUT 100

@interface CSDStudentViewController ()
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSArray *fieldsNames;
@property (nonatomic, strong) NSMutableArray *categoryFields;
@property (nonatomic, strong) NSMutableArray *categoryFieldsNames;

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSArray *requiredFields;
@property (nonatomic, strong) NSArray *pickerFields;
@property (nonatomic, strong) NSArray *disabledFields;
@property (nonatomic, strong) NSArray *switchFields;
@property (nonatomic, strong) NSArray *percentageFields;
@property (nonatomic, strong) NSArray *numericFields;

@property (nonatomic, strong) NSArray *datePickerFieldsNames;

@property (nonatomic, strong) NSDate *dateTime;

@property (nonatomic, assign) BOOL isCategory;

@property (nonatomic, assign) BOOL isSaveEnabled;

@property (nonatomic, strong) UIAlertController *al;

@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSString *selectedGroup;

@end

@implementation CSDStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    
    if ([self.user existsOnServerNew]) {
        self.fields = [NSArray arrayWithObjects:@"company", @"firstname", @"middleName", @"surname",@"driverLicenseClass", @"driverLicenseNumber", @"driverLicenseState", @"endorsements", @"correctiveLensRequired", nil];
        self.fieldsNames = [NSArray arrayWithObjects:@"Company", @"First Name", @"Middle Name", @"Last Name", @"Class", @"Driver License Number", @"Driver License State", @"Endorsements", @"Corrective Lens Required", nil];
        //self.requiredFields = [NSArray arrayWithObjects:@"company", @"firstname", @"middleName", @"surname", @"studentClass", @"driverLicenseNumber", @"driverLicenseState",  nil];
        
        //07.06.2019
        if ([self ignoreDriverFields]) {
            self.requiredFields = [NSArray arrayWithObjects:@"company", @"firstname", @"middleName", @"surname", nil];
            // 09.12.2019
            self.requiredFields = [NSArray arrayWithObjects:@"company", @"firstname", @"surname", nil];

        } else {
            self.requiredFields = [NSArray arrayWithObjects:@"company", @"firstname", @"middleName", @"surname", @"driverLicenseClass", @"driverLicenseNumber", @"driverLicenseState", nil];
            // 09.12.2019
            self.requiredFields = [NSArray arrayWithObjects:@"company", @"firstname", @"surname", @"driverLicenseClass", @"driverLicenseNumber", @"driverLicenseState", nil];
        }
    } else {
        self.fields = [NSArray arrayWithObjects:@"company", @"firstname", @"middleName", @"surname", @"email", @"password", @"driverLicenseClass", @"driverLicenseNumber", @"driverLicenseState", @"driverLicenseExpirationDate", @"endorsements", @"correctiveLensRequired", @"dOTExpirationDate", @"userGroupName", nil];
        
        self.fieldsNames = [NSArray arrayWithObjects:@"Company", @"First Name", @"Middle Name", @"Last Name", @"Email", @"Password", @"Class", @"Driver License Number", @"Driver License State", @"Driver License Expiration Date", @"Endorsements", @"Corrective Lens Required", @"DOT Expiration Date", @"User Group", nil];
        
        if ([self.userItemType isEqualToString:kUserTypeInstructor]) {
            self.fields = [NSArray arrayWithObjects:@"company", @"firstname", @"middleName", @"surname", @"email", @"password", @"driverLicenseClass", @"driverLicenseNumber", @"driverLicenseState", @"driverLicenseExpirationDate", @"endorsements", @"correctiveLensRequired", @"dOTExpirationDate", @"userGroupName", @"employeeNumber", nil];
        
            self.fieldsNames = [NSArray arrayWithObjects:@"Company", @"First Name", @"Middle Name", @"Last Name", @"Email", @"Password", @"Class", @"Driver License Number", @"Driver License State", @"Driver License Expiration Date", @"Endorsements", @"Corrective Lens Required", @"DOT Expiration Date", @"User Group",  @"Employee Id",  nil];
        }
        
        if ([self ignoreDriverFields]) {
            self.requiredFields = [NSArray arrayWithObjects:@"company", @"firstname", @"surname", @"email", @"password", @"userGroupName", nil];
            if ([self.userItemType isEqualToString:kUserTypeInstructor]) {
                self.requiredFields = [NSArray arrayWithObjects:@"company", @"firstname", @"surname", @"email", @"password", @"userGroupName", @"employeeNumber", nil];
            }
        } else {
            self.requiredFields = [NSArray arrayWithObjects:@"company", @"firstname", @"surname", @"email", @"password", @"driverLicenseClass", @"driverLicenseNumber", @"driverLicenseState", @"userGroupName", nil];
        }
    }
    
    self.switchFields = [NSArray arrayWithObjects:@"endorsements", @"correctiveLensRequired", nil];
    
    if ([self.userItemType isEqualToString:kUserTypeStudent]) {
        self.pickerFields = [NSArray arrayWithObjects:@"companyName", @"driverLicenseState", @"driverLicenseClass", nil];
    } else {
        self.pickerFields = [NSArray arrayWithObjects:@"driverLicenseState", @"driverLicenseClass", nil];
    }
    
    self.datePickerFieldsNames = [NSArray arrayWithObjects:@"dOTExpirationDate", @"driverLicenseExpirationDate", nil];
    
    if (![self.user existsOnServerNew]) {
        NSMutableArray *pickFields = [NSMutableArray arrayWithArray:self.pickerFields];
        [pickFields addObject:@"userGroupName"];
        self.pickerFields = [NSArray arrayWithArray:pickFields];
    }

    self.values = [NSMutableDictionary dictionary];
    
    if (![self.user existsOnServerNew]) {
        [self generateUserGroup];
    }
    
    NSLog(@"Company %@", self.company);
    
    if (self.company) {
        if (self.company.name) {
            [self.values setObject:self.company.name forKey:Key_Company];
        }
        
//        if (self.company.companyId) {
//            [self.values setObject:self.company.companyId forKey:Key_Company_Id];
//        }
        [self loadCategoryFieldsFromObject:self.company];
    }

    [self loadObject];
    self.title = [self getScreenTitle];
    
    if (![self.user existsOnServerNew]) {
        [self.actionButton setEnabled:NO];
    } else {
        if (self.showGroupActions) {
            [self.actionButton setEnabled:YES];
        }
    }
    
    [self getUserGroups];
}

-(void)generateUserGroup {
#ifdef APP_CSD
    NSString *name = [NSString stringWithFormat:@"%@ %@", self.company.name, [self getUserTypePlural]];
    self.selectedGroup = name;
    [self.values setObject:self.selectedGroup forKey:Key_UserGroup];
#endif
}

-(NSString*)getUserTypePlural {
    if (self.userItemType.length) {
        return [NSString stringWithFormat:@"%@s", [self.userItemType capitalizedString]];
    }
    return nil;
}

-(BOOL)ignoreDriverFields {
    if ([self.userItemType isEqualToString:kUserTypeStudent] || [self.userItemType isEqualToString:kUserTypeDriver]) {
        return NO;
    }
    return YES;
}

-(void)getUserGroups {
    /*
    self.progressHUD.labelText = @"Please wait while getting User Groups!...";
    
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    */
    [self performSelector:@selector(_getUserGroups) withObject:nil afterDelay:0.1];
}

-(void)_getUserGroups {
    UserAggregate *usrAgg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    [usrAgg registerForCallback:self];
    [usrAgg getUserGroupsForCompany:nil];
}

-(void)loadCategoryFieldsFromObject:(RCOObject*)object {
    self.categoryFields = [NSMutableArray array];
    self.categoryFieldsNames = [NSMutableArray array];

    for (NSInteger i = 1; i <= 6; i++) {
        NSString *categoryName = [NSString stringWithFormat:@"category%dName", (int)i];
        NSString *categoryValue = [NSString stringWithFormat:@"category%dValue", (int)i];
        SEL nameSel = NSSelectorFromString(categoryName);
        SEL valSel = NSSelectorFromString(categoryValue);
        
        NSString *name = nil;
        
        if ([object respondsToSelector:nameSel]) {
            name = [object valueForKey:categoryName];
            if (name.length) {
                [self.categoryFields addObject:name];
            }
        }

        if (name.length && [object respondsToSelector:valSel]) {
            NSString *val = [object valueForKey:categoryValue];
            if (val.length) {
                [self.values setObject:val forKey:name];
            }
        }
    }
    NSLog(@"");
}

-(IBAction)actionButtonPressed:(UIBarButtonItem*)sender {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Options", nil)
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *moveToGroupAction = [UIAlertAction actionWithTitle:@"Add to Group"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self showGroupPickerFromView:sender];
                                                                 }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [al addAction:moveToGroupAction];
    [al addAction:cancelAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(void)showGroupInput {
    if (![self.user existsOnServerNew]) {
        [self showSimpleMessage:@"Please save first the user!"];
        return;
    }
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
        textField.tag = TAG_GROUP_INPUT;
        [textField addTarget:weakSelf action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        
    }];
    
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           UITextField *input = self.al.textFields[0];
                                                           [self addToGroup:input.text];
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

-(void)askMoveToGroup {
    self.al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Move to Group?", nil)
                                                  message:self.selectedGroup
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Move", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self addToGroup:self.selectedGroup];
                                                       }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [self.al addAction:saveAction];
    [self.al addAction:cancelAction];
    [self presentViewController:self.al animated:YES completion:nil];
}

-(void)addToGroup:(NSString*)groupName {
    NSLog(@"");
    
    self.progressHUD.labelText = @"Move User to Group...";
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];

    UserAggregate *agg = (UserAggregate*)[self aggregate];
    [agg registerForCallback:self];
    [agg moveUserToGroup:self.user.rcoObjectId groupName:groupName];
}

-(IBAction)viewChanged:(UISegmentedControl*)sender {
    self.isCategory = sender.selectedSegmentIndex;
    if (!self.isCategory) {
        [self enableSaveBtn];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    [self.tableView reloadData];
}

-(void)loadNotes {
}

-(NSString*)getScreenTitle {
    if (!self.user) {
        return [NSString stringWithFormat:@"New %@", [self getUserRecordType]] ;
    } else {
        return [self getUserRecordType];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self aggregate] registerForCallback:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self aggregate] unRegisterForCallback:self];
}

-(void)loadObject {
    for (NSString *field in self.fields) {
        NSString *value = [self.user valueForKey:field];
        if (value) {
            [self.values setObject:value forKey:field];
        }
    }
    if (self.user) {
        [self loadCategoryFieldsFromObject:self.user];
    }
    [self.tableView reloadData];
}

-(IBAction)cancelButtonPressed:(id)sender {
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(IBAction)saveButtonPressed:(id)sender {
    NSString *message = [self validateInputs];
    
    if (message) {
        [self showSimpleMessage:message];
        return;
    }
    [self checkExistingRecord];
}

-(void)checkExistingUserRecord {
    self.progressHUD.labelText = @"Check existing Record ...";
    
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    
    [self performSelector:@selector(checkExistingRecord) withObject:nil afterDelay:0.1];
}

-(void)checkExistingRecord {
    UserAggregate *agg = (UserAggregate*)[self aggregate];
    
    NSString *number = [self.values objectForKey:@"driverLicenseNumber"];
    NSString *state = [self.values objectForKey:@"driverLicenseState"];
    [agg getRMSUserWithDriverLicenseNumber:number andState:state];
    
}

-(void)createOrUpdateRecord {
    if (self.user) {
        self.progressHUD.labelText = @"Update record...";
    } else {
        self.progressHUD.labelText = @"Create record...";
    }
    
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    
    [self performSelector:@selector(_createOrUpdateRecord) withObject:nil afterDelay:0.1];
}

-(NSString*)getUserRecordType {
    
    if ([self.userItemType isEqualToString:kUserTypeStudent]) {
        return @"Student";
    } else if ([self.userItemType isEqualToString:kUserTypeInstructor]) {
        return @"Instructor";
    } else if ([self.userItemType isEqualToString:kUserTypeStaff]) {
        return @"Staff";
    } else if ([self.userItemType isEqualToString:kUserTypeTechnician]) {
        return @"Technician";
    }  else if ([self.userItemType isEqualToString:kUserTypeLabor]) {
        return @"Labor";
    } else if ([self.userItemType isEqualToString:kUserTypeCustomer]) {
        return @"Customer";
    } else if ([self.userItemType isEqualToString:kUserTypeVendor]) {
        return @"Vendor";
    } else if ([self.userItemType isEqualToString:kUserTypeDealer]) {
        return @"Dealer";
    } else if ([self.userItemType isEqualToString:kUserTypeDriver]) {
        return @"Driver";
    }
    return nil;
}


-(NSString*)getBooleanFromValue:(NSNumber*)val {
    if ([val boolValue]) {
        return @"yes";
    }
    return @"no";
}

-(void)_createOrUpdateRecord {
    
    User *usr = nil;
    
    if (!self.user) {
        usr = (User*)[[self aggregate] createNewObject];
        usr.dateTime = [NSDate date];
        self.user = usr;
        usr.itemType = self.userItemType;
    } else {
        // if the item exists the we should update it
        usr = self.user;
    }
    
    for (NSString *field in self.fields) {
        id val = [self.values objectForKey:field];
        if (val) {
            if ([self.switchFields containsObject:field]) {
                [usr setValue:[self getBooleanFromValue:val] forKey:field];
            } else {
                [usr setValue:val forKey:field];
            }
        }
    }
    
    // Save category Fields
    for (NSInteger i = 0; i < self.categoryFields.count; i++) {
        NSString *categoryNameCodingField = [NSString stringWithFormat:@"category%dName", (int)(i+1)];
        NSString *categoryValueCodingField = [NSString stringWithFormat:@"category%dValue", (int)(i+1)];
        NSString *categoryName = [self.categoryFields objectAtIndex:i];
        NSString *categoryValue = [self.values objectForKey:categoryName];
        [self.user setValue:categoryValue forKey:categoryValueCodingField];
        [self.user setValue:categoryName forKey:categoryNameCodingField];
    }
    
    if ([usr existsOnServerNew]) {
        UserAggregate *agg = (UserAggregate*)[self aggregate];
        [agg updateObject:usr];
    } else {
        [usr setNeedsUploading:YES];
        
        NSLog(@"User %@", usr);
        
        [[self aggregate] createNewRecord:usr];
        
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSavedAccessToken];
        
        NSMutableDictionary *studentParams = [[NSMutableDictionary alloc] init];
        
        if ([HelperSharedManager isCheckNotNULL:usr.firstname]) {
            [studentParams setValue:usr.firstname forKey:@"first_name"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.surname]) {
            [studentParams setValue:usr.surname forKey:@"last_name"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.middleName]) {
            [studentParams setValue:usr.middleName forKey:@"middle_name"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.email]) {
            [studentParams setValue:usr.email forKey:@"email"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.password]) {
            [studentParams setValue:usr.password forKey:@"password"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.sex]) {
            [studentParams setValue:usr.sex forKey:@"sex"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.dateOfBirth]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-mm-dd"];

            //Optionally for time zone conversions
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];

            NSString *stringFromDate = [formatter stringFromDate:usr.dateOfBirth];
            
            
            [studentParams setValue:stringFromDate forKey:@"date_of_birth"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.homePhoneNumber]) {
            [studentParams setValue:usr.homePhoneNumber forKey:@"home_phone_number"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.workPhoneNumber]) {
            [studentParams setValue:usr.workPhoneNumber forKey:@"work_phone_number"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.mobilePhoneNumber]) {
            [studentParams setValue:usr.mobilePhoneNumber forKey:@"mobile_number"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.phone]) {
            [studentParams setValue:usr.phone forKey:@"phone"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.sendGPSLocation]) {
            [studentParams setValue:usr.sendGPSLocation forKey:@"send_gps_location"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.getUserGroupName]) {
            NSString *groupName = usr.userGroupName;
            NSArray *groups = @[groupName];
            [studentParams setValue:groups forKey:@"groups"];
        }
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        if ([HelperSharedManager isCheckNotNULL:usr.companyId]) {
            
            [info setValue:usr.companyId forKey:@"company"];
        } else {
            [info setValue:@"0" forKey:@"company"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.driverLicenseNumber]) {
            
            [info setValue:usr.driverLicenseNumber forKey:@"driver_license_number"];
        } else {
            [info setValue:@"" forKey:@"driver_license_number"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.driverLicenseState]) {
            
            [info setValue:usr.driverLicenseState forKey:@"driver_license_state"];
        }  else {
            [info setValue:@"" forKey:@"driver_license_state"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.driverLicenseExpirationDate]) {
            
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-mm-dd"];

            //Optionally for time zone conversions
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];

            NSString *stringFromDate = [formatter stringFromDate:usr.driverLicenseExpirationDate];
            
            [info setValue:stringFromDate forKey:@"driver_license_expire_date"];
        } else {
            [info setValue:@"" forKey:@"driver_license_expire_date"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.dOTExpirationDate]) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-mm-dd"];

            //Optionally for time zone conversions
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];

            NSString *stringFromDate = [formatter stringFromDate:usr.dOTExpirationDate];
            
            [info setValue:stringFromDate forKey:@"dot_expiration_date"];
        } else {
            [info setValue:@"" forKey:@"dot_expiration_date"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.endorsements]) {
            
            [info setValue:usr.endorsements forKey:@"endorsements"];
        } else {
            [info setValue:@"false" forKey:@"endorsements"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.driverLicenseClass]) {
            
            [info setValue:usr.driverLicenseClass forKey:@"driver_license_class"];
        } else {
            [info setValue:@"" forKey:@"driver_license_class"];
        }
        
        if ([HelperSharedManager isCheckNotNULL:usr.correctiveLensRequired]) {
            
            [info setValue:usr.correctiveLensRequired forKey:@"corrective_lense_required"];
        } else {
            [info setValue:@"false" forKey:@"corrective_lense_required"];
        }
        
        [studentParams setValue:info forKey:@"info"];
        
        
        NSLog(@"Student %@", studentParams);
        
        [[ServerManager sharedManager] postStudent:token params:studentParams success:^(id responseObject) {
            
            [self.progressHUD hide: self.view];
            
        } failure:^(NSString *failureReason, NSInteger statusCode) {
            [self.progressHUD hide: self.view];
        }];
        
    }
}

-(IBAction)deleteButtonPressed:(id)sender {
    
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete current User", nil)
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            NSLog(@"");
                                                        }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * action) {
                                                          NSLog(@"");
                                                      }];

    [al addAction:yesAction];
    [al addAction:noAction];

    [self presentViewController:al animated:YES completion:nil];
}

-(NSString*)validateInputs {
    
    for (NSString *key in self.requiredFields) {
        NSObject *obj = [self.values objectForKey:key];
        if (!obj) {
            //get the coding field name
            NSInteger index = [self.fields indexOfObject:key];
            NSString *fieldName = [self.fieldsNames objectAtIndex:index];
            NSString *message = [NSString stringWithFormat:@"%@ was not set!", fieldName];
            return message;
        }
    }
    return nil;
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isCategory) {
        return self.categoryFields.count;
    } else {
        return self.fields.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (self.isCategory) {
        title = [self.categoryFields objectAtIndex:section];
    } else {
        //NSString *key = [self.fields objectAtIndex:section];
        title = [self.fieldsNames objectAtIndex:section];
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *key = nil;
    NSString *value = nil;
    if (self.isCategory) {
        key = [self.categoryFields objectAtIndex:indexPath.section];
        value = [self.values objectForKey:key];
    } else {
        key = [self.fields objectAtIndex:indexPath.section];
        value = [self.values objectForKey:[NSString stringWithFormat:@"%@", key]];
    }
    
    BOOL requiredField = [self.requiredFields containsObject:key];
    
    UILabel *requiredLbl = nil;
    if (requiredField) {
        requiredLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        requiredLbl.text = @"*";
        [requiredLbl setTextColor:[UIColor redColor]];
    }
    
    if ([self.switchFields containsObject:key]) {
        
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"switchCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchCell"];
        }

        NSInteger keyIndex = [self.switchFields indexOfObject:key];

        UISwitch *sw = [[UISwitch alloc] init];
        
        sw.tag = keyIndex;
        sw.on = [value boolValue];

        [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = key;
        // 27.05.2019 there is no point in displaying extra text for switch
        cell.textLabel.text = nil;
        cell.imageView.image = nil;
        return cell;

    } else if ([self.datePickerFieldsNames containsObject:key]) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"dateCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
        }
        
        NSDate *date = [self.values objectForKey:key];
        
        if (date) {
            if ([key isEqualToString:@"dateTime"]) {
                cell.textLabel.text = [[self aggregate] rcoDateAndTimeToString:date];
            } else {
                cell.textLabel.text = [[self aggregate] rcoDateToString:date];
            }
        } else {
            cell.textLabel.text = nil;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = requiredLbl;
        cell.imageView.image = [UIImage imageNamed:@"CALENDAR"];
        return cell;
        
    } else if ([self.pickerFields containsObject:key]) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"PickerCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PickerCell"];
        }
        
        if ([key isEqualToString:Key_State]) {
            NSString *abbreviation = value;
            value = [RCOObject getStateNameForAbbreviation:abbreviation andFormatted:YES];
        }

        cell.textLabel.text = value;
        
        if (value) {
            cell.accessoryView = nil;
        } else {
            cell.accessoryView = requiredLbl;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = nil;
        return cell;
    }
    
    // we have input cell
    InputCell *inputCell = nil;
    
    inputCell = (InputCell*)[theTableView dequeueReusableCellWithIdentifier:@"InputCell"];
    
    if (inputCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InputCell"
                                                     owner:self
                                                   options:nil];
        inputCell = (InputCell *)[nib objectAtIndex:0];
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [NSString stringWithFormat:@"%@", value];
    }

    //configure input
    CGRect frame = inputCell.titleLabel.frame;
    // hide title label
    frame.size.width = 0;
    inputCell.titleLabel.frame = frame;
    // resize input field
    frame = inputCell.inputTextField.frame;
    frame.origin.x = 10;
    // we should maximize the width
    frame.size.width = inputCell.frame.size.width - 20;
    
    [inputCell.requiredLabel setHidden:!requiredField];
    
    inputCell.inputTextField.frame = frame;
    
    inputCell.inputTextField.delegate = self;
    
    [inputCell.inputTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    inputCell.inputTextField.tag = indexPath.section;
    
    inputCell.inputTextField.font = [UIFont boldSystemFontOfSize:19];
    
    inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    inputCell.inputTextField.text = value;
    inputCell.inputTextField.inputAccessoryView = self.keyboardToolbar;

    if ([self.numericFields containsObject:key]) {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDefault;
    }

    if ([self.disabledFields containsObject:key]) {
        inputCell.inputTextField.enabled = NO;
        [inputCell.inputTextField setTextColor:[UIColor grayColor]];
    } else {
        inputCell.inputTextField.enabled = YES;
        [inputCell.inputTextField setTextColor:[UIColor darkTextColor]];
    }
    
    inputCell.inputTextField.font = [UIFont systemFontOfSize:15];
    
    if ([self.percentageFields containsObject:key]) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        lbl.text = @"%";
        inputCell.accessoryView = lbl;
        inputCell.inputTextField.keyboardType = UIKeyboardTypeDecimalPad;
    } else {
        inputCell.accessoryView = nil;
    }
    
    return inputCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSString *key = [self.fields objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([key isEqualToString:Key_UserGroup]) {
        [self showGroupPickerFromView:cell];
    } else if ([key isEqualToString:Key_Company]) {
        [self showCompanyPickerFromView:cell];
    } else if ([key isEqualToString:Key_State]) {
        [self showDriverLicenseStatePickerFromView:cell];
    } else if ([key isEqualToString:Key_Class]) {
        [self showClassPickerFromView:cell];
    } else if ([self.datePickerFieldsNames containsObject:key]) {
        [self showDatePickerFromView:cell andKey:key];
    }
}

-(void)switchValueChanged:(UISwitch*)aSwitch {
    NSInteger keyIndex = aSwitch.tag;
    NSString *key = [self.switchFields objectAtIndex:keyIndex];
    
    [self.values setObject:[NSNumber numberWithBool:aSwitch.on] forKey:key];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showCompanyPickerFromView:(UIView*)fromView{
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    title = @"Students";
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
    listController.selectedItem = self.company;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showDriverLicenseStatePickerFromView:(UIView*)fromView {
    /*
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"USStateAbbreviations" ofType:@"plist"];
    NSDictionary *stateAbbreviationsMap = [[NSDictionary alloc] initWithContentsOfFile:plist];
    
    NSArray *states = [stateAbbreviationsMap.allValues sortedArrayUsingSelector:@selector(compare:)];
    */
    NSArray *states = [RCOObject getStatesList:YES andAbbreviation:YES];
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:states
                                                                                                forKey:Key_State];
    
    listController.selectDelegate = self;
    listController.title = @"State";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *state = [self.values objectForKey:Key_State];
    if (state) {
        state = [NSString stringWithFormat:@"%@",[RCOObject getStateNameForAbbreviation:state andFormatted:YES]];
        listController.selectedValue = state;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showGroupPickerFromView:(id)fromView {
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.groups
                                                                                                forKey:Key_UserGroup];
    
    listController.selectDelegate = self;
    listController.title = @"Groups";
    listController.showIndex = NO;
    listController.newLogic = YES;
    if ([self.user existsOnServerNew]) {
        // is moving to a group ...
        if (self.selectedGroup) {
            listController.selectedValue = self.selectedGroup;
        }
    } else {
        // is seleting the group when adding
        NSString *selectedGrp = [self.values objectForKey:Key_UserGroup];
        if (selectedGrp.length) {
            listController.selectedValue = selectedGrp;
        }
    }
    
    if (DEVICE_IS_IPAD) {
        if ([fromView isKindOfClass:[UIBarButtonItem class]]) {
            [self showPopoverForViewController:listController fromBarButton:(UIBarButtonItem*)fromView];
        } else {
            [self showPopoverForViewController:listController fromView:(UIView *)fromView];
        }
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showClassPickerFromView:(UIView*)fromView {
    
    NSArray *values = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:values
                                                                                                forKey:Key_Class];
    
    listController.selectDelegate = self;
    listController.title = @"Class";
    listController.showIndex = NO;
    listController.newLogic = YES;
    NSString *class = [self.values objectForKey:Key_Class];
    if (class) {
        listController.selectedValue = class;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}


-(void)showDatePickerFromView:(UIView*)fromView andKey:(NSString*)key  {
    DateSelectorViewController *controller = [[DateSelectorViewController alloc] initWithNibName:@"DateSelectorViewController"
                                                                                          bundle:nil
                                                                                        forDates:[NSArray arrayWithObject:key]];
    controller.selectDelegate = self;
    controller.shouldPopUpOnIpad = YES;
    
    NSDate *date = [self.values objectForKey:key];
    
    if (!date) {
        date = [NSDate date];
    }
    
    controller.title = @"Date";
    controller.isSimpleDatePicker = YES;

    NSInteger index = [self.fields indexOfObject:key];
    if (index != NSNotFound) {
        NSString *name = [self.fieldsNames objectAtIndex:index];
        controller.dateNames = [NSArray arrayWithObject:name];
    }
    
    controller.currentDate = date;
    
    if (DEVICE_IS_IPHONE) {
        controller.isCancelNewLogic = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self showPopoverForViewController:controller fromView:fromView];
    }
}

#pragma mark -
#pragma mark UItextFieldDelegate Methods

- (IBAction)textFieldChanged:(UITextField*) textField {
    if (textField.tag == TAG_GROUP_INPUT) {
        NSArray *actions = self.al.actions;
        UIAlertAction *sendAction = [actions objectAtIndex:0];
        
        if ([textField.text length] > 3) {
            // we should enable send button
            [sendAction setEnabled:YES];
        } else {
            [sendAction setEnabled:NO];
        }
        return;
    }
    NSString *keyString = nil;
    if (self.isCategory) {
        keyString = [self.categoryFields objectAtIndex:textField.tag];
    } else {
        keyString = [self.fields objectAtIndex:textField.tag];
    }
    NSString *value = textField.text;
    [self.values setObject:[value stringByReplacingOccurrencesOfString:@"\n" withString:@" "] forKey:keyString];
    self.isSaveEnabled = YES;
    [self enableSaveBtn];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([key isEqualToString:Key_UserGroup]) {
        if ([object isKindOfClass:[NSString class]]) {
            if ([self.user existsOnServerNew]) {
                // we want to move the user to a new group
                self.selectedGroup = (NSString*)object;
                //[self askMoveToGroup];
                [self performSelector:@selector(askMoveToGroup) withObject:nil afterDelay:0.2];
            } else {
                // we selected a group for the user when we create the user
                [self.values setObject:object forKey:key];
            }
        }
    } else if ([object isKindOfClass:[NSDate class]]) {
        [self.values setObject:object forKey:key];
        self.isSaveEnabled = YES;
    } else if ([key isEqualToString:Key_Class]) {
        if (object) {
            [self.values setObject:object forKey:key];
            self.isSaveEnabled = YES;
        }
    } else if ([key isEqualToString:Key_State]) {
        if (object) {
            NSString *state = [RCOObject getStateAbbreviationFromString:(NSString*)object];
            if (state.length) {
                [self.values setObject:state forKey:key];
            } else {
                [self.values setObject:object forKey:key];
            }
            self.isSaveEnabled = YES;
        }
    } else if ([key isEqualToString:Key_Company]) {
        if ([object isKindOfClass:[TrainingCompany class]]) {
            self.company = (TrainingCompany*)object;
            if (self.company.name) {
                [self.values setObject:self.company.name forKey:key];
            }
            
//            if (self.company.companyId) {
//                [self.values setObject:self.company.companyId forKey:Key_Company_Id];
//            }
            [self loadCategoryFieldsFromObject:self.company];
            self.isSaveEnabled = YES;
        }
    }

    [self enableSaveBtn];
    
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

    [self.tableView reloadData];
}

-(void)enableSaveBtn {
    [self.navigationItem.rightBarButtonItem setEnabled:self.isSaveEnabled];
}

-(Aggregate*)aggregate {
    if (self.userItemType.length) {
        return [[DataRepository sharedInstance] getAggregateForClass:self.userItemType];
    } else if (self.user.itemType) {
        return [[DataRepository sharedInstance] getAggregateForClass:self.user.itemType];
    } else {
        return nil;
    }
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [messageInfo objectForKey:@"message"];
    
    if ([message isEqualToString:RD_G_R_U_X_F]) {
        NSString *objId = [messageInfo objectForKey:@"objId"];
        
        if ([objId isEqualToString:UserWithDriverLicenseNumberAnState]) {
            NSArray *values = [messageInfo objectForKey:RESPONSE_OBJ];
            NSLog(@"");
            if (values.count > 0) {
                for (NSDictionary *dict in values) {
                    NSMutableDictionary *mapCodingInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [mapCodingInfo addEntriesFromDictionary:[dict objectForKey:@"mapCodingInfo"]];
                    NSString *recordId = [mapCodingInfo objectForKey:@"RecordId"];
                    NSString *firstName = [mapCodingInfo objectForKey:@"First Name"];
                    NSString *lastName = [mapCodingInfo objectForKey:@"Last Name"];
                    NSString *company = [mapCodingInfo objectForKey:@"Company"];

                    if (self.user.rcoRecordId) {
                        if ([self.user.rcoRecordId isEqualToString:recordId]) {
                            // this is an "update"
                            [self createOrUpdateRecord];
                        } else {
                            // this is the driver license number and state are already used by other record
                            NSString *msg = [NSString stringWithFormat:@"Driver License Number & State are already used by:\n\n%@,%@\n from company:\n%@", lastName, firstName, company];
                            [self showSimpleMessage:msg];
                        }
                    } else {
                        // this is a new user and we already have this combination ( driver license state and number) set for other user
                        NSString *msg = [NSString stringWithFormat:@"Driver License Number & State are already used by:\n\n%@,%@\n\nfrom company:\n%@", lastName, firstName, company];
                        [self showSimpleMessage:msg];
                    }
                }
            } else {
                if (!values) {
                    //19.05.2020  this might be the response for working offline so we should check locally also
                    UserAggregate *agg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];

                    NSString *lastName = [self.values objectForKey:@"surname"];
                    NSString *firstName = [self.values objectForKey:@"firstname"];;
                    NSString *company = [self.values objectForKey:@"company"];;
                    NSString *driverLicenseNumber = [self.values objectForKey:@"driverLicenseNumber"];;
                    NSString *driverLicenseState = [self.values objectForKey:@"driverLicenseState"];;
                    
                    User *user = [agg getAnyUserWithDriverLicenseNumber:driverLicenseNumber
                                                  andDriverLicenseState:driverLicenseState];
                    NSString *mobileRecordId = user.rcoMobileRecordId;

                    if (user) {
                        if (self.user.rcoMobileRecordId) {
                            if ([self.user.rcoMobileRecordId isEqualToString:mobileRecordId]) {
                                // this is an "update"
                                [self createOrUpdateRecord];
                            } else {
                                // this is the driver license number and state are already used by other record
                                NSString *msg = [NSString stringWithFormat:@"Driver License Number & State are already used by:\n\n%@,%@\n from company:\n%@", lastName, firstName, company];
                                [self showSimpleMessage:msg];
                                return;
                            }
                        } else {
                            // this is a new user and we already have this combination ( driver license state and number) set for other user
                            NSString *msg = [NSString stringWithFormat:@"Driver License Number & State are already used by:\n\n%@,%@\n\nfrom company:\n%@", lastName, firstName, company];
                            [self showSimpleMessage:msg];
                            return;
                        }
                    } else {
                        // this combination does not exist in the system, so we can continue with the logic
                        [self createOrUpdateRecord];
                    }
                } else {
                    // this combination does not exist in the system, so we can continue with the logic this is regular response from server
                    [self createOrUpdateRecord];
                }
            }
        } else if ([objId isEqualToString:UserGroupRecords]) {
            
            NSMutableArray *groups = [NSMutableArray array];
            
            NSArray *values = [messageInfo objectForKey:RESPONSE_OBJ];
            if (values.count > 0) {
                for (NSDictionary *dict in values) {
                    NSMutableDictionary *mapCodingInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [mapCodingInfo addEntriesFromDictionary:[dict objectForKey:@"mapCodingInfo"]];
                    NSString *groupName = [mapCodingInfo objectForKey:@"ObjectName"];
                    if (groupName) {
                        [groups addObject:groupName];
                    }
                }
            }
            
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
            [groups sortUsingDescriptors:[NSArray arrayWithObject:sd]];
            
            [aggregate unRegisterForCallback:self];
            self.groups = [NSArray arrayWithArray:groups];
            NSLog(@"");
        }
    } else if ([message isEqualToString:MOVE_USER_TO_GROUP]) {
        [self showSimpleMessage:@"User successfully moved!"];
        [self.progressHUD hide:YES];
    } else if ([message isEqualToString:SET_USERS] || [message isEqualToString:R_S_C_1]) {
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.addDelegate didAddObject:self.user forKey:self.addDelegateKey];
        }
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
    //NSString *errorMessage = [messageInfo objectForKey:@"errorMessage"];
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:RD_G_R_U_X_F]) {
        NSString *objId = [messageInfo objectForKey:@"objId"];
        
        if ([objId isEqualToString:UserWithDriverLicenseNumberAnState]) {
            NSLog(@"");
            UserAggregate *agg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
            
            NSString *lastName = [self.values objectForKey:@"surname"];
            NSString *firstName = [self.values objectForKey:@"firstname"];;
            NSString *company = [self.values objectForKey:@"company"];;
            NSString *driverLicenseNumber = [self.values objectForKey:@"driverLicenseNumber"];;
            NSString *driverLicenseState = [self.values objectForKey:@"driverLicenseState"];;
            
            User *user = [agg getAnyUserWithDriverLicenseNumber:driverLicenseNumber
                                          andDriverLicenseState:driverLicenseState];
            NSString *mobileRecordId = user.rcoMobileRecordId;
            if (user) {
                if (self.user.rcoMobileRecordId) {
                    if ([self.user.rcoRecordId isEqualToString:mobileRecordId]) {
                        // this is an "update"
                        [self createOrUpdateRecord];
                    } else {
                        // this is the driver license number and state are already used by other record
                        NSString *msg = [NSString stringWithFormat:@"Driver License Number & State are already used by:\n\n%@,%@\n from company:\n%@", lastName, firstName, company];
                        [self showSimpleMessage:msg];
                        return;
                    }
                } else {
                    // this is a new user and we already have this combination ( driver license state and number) set for other user
                    NSString *msg = [NSString stringWithFormat:@"Driver License Number & State are already used by:\n\n%@,%@\n\nfrom company:\n%@", lastName, firstName, company];
                    [self showSimpleMessage:msg];
                    return;
                }
            } else {
                // this combination does not exist in the system, so we can continue with the logic
                [self createOrUpdateRecord];
            }
        }
    } else if ([message isEqualToString:MOVE_USER_TO_GROUP]) {
        [self showSimpleMessage:@"Failed to move user!"];
        [self.progressHUD hide:YES];
    } else  if ([message isEqualToString:SET_USERS] || [message isEqualToString:R_S_C_1]) {
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
    }
}

#pragma mark Keyboard Methods

- (void)keyboardWillHide:(NSNotification *)notif {
    self.currentIndexPath = nil;
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

- (void)keyboardWillShow:(NSNotification *)notif{
    self.keyboardInfo = notif.userInfo;
    NSInteger keyBoardHeight = [[self.keyboardInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size.height;
    UIEdgeInsets contentInset = UIEdgeInsetsMake(0.0, 0.0, keyBoardHeight, 0.0);
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

@end
