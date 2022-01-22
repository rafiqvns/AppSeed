//
//  CSDScoresFilterViewController.m
//  CSD
//
//  Created by .D. .D. on 12/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDScoresFilterViewController.h"
#import "TrainingScoreAggregate.h"
#import "DataRepository.h"
#import "NSDate+Misc.h"
#import "NSDate+CalendarGrid.h"
#import "TrainingStudent+CoreDataClass.h"
#import "TrainingDriverStudentAggregate.h"
#import "TrainingCompany+CoreDataClass.h"
#import "TrainingCompanyAggregate.h"
#import "UserAggregate.h"
#import "User.h"
#import "DateSelectorViewController.h"
#import "TestFormAggregate.h"
#import "Settings.h"
#import "RCOValuesListViewController.h"
#import "RCOObjectListViewController.h"
#import "CSDScoreDetailCell.h"
#import "TrainingTestInfo+CoreDataClass.h"
#import "InputCell.h"

#define KeyDateFrom @"From Date"
#define KeyDateTo @"To Date"
#define KeyStudent @"student"
#define KeyTestName @"Test Name"
#define KEY_Chart @"chart"
#define KeyFilterField @"filterField"
#define KeyCategories @"categories"

#define KeyFilterInstructorId @"Instructor Employee Id"
#define KeyFilterInstructorFirstName @"Instructor First Name"
#define KeyFilterInstructorLastName @"Instructor Last Name"

#define KeyFilterDriverLicenseNumber @"Driver License Number"
#define KeyFilterDriverLicenseState @"Driver License State"

#define KeyFilterStudentFirstName @"Student First Name"
#define KeyFilterStudentLastName @"Student Last Name"

#define KeyScoreOrgNumber @"scoreOrgNumber"
#define KeyScoreStudentFirstName @"scoreStudentFirstName"
#define KeyScoreStudentLastName @"scoreStudentLastName"
#define KeyScoreStudentId @"scoreStudentId"
#define KeyScoreTestName @"scoreTestName"
#define KeyScoreStartDate @"scoreStartDate"
#define KeyScoreEndDate @"scoreEndDate"
#define KeyScoreElapsedTime @"scoreElapsedTime"
#define KeyScorePointsPossible @"scorePointsPossible"
#define KeyScorePointsReceived @"scorePointsReceived"
#define KeyScoreTotal @"scoreTotal"

#define SortTypeName 0
#define SortTypeScore 1
#define SortTypeDate 2


@interface CSDScoresFilterViewController ()
@property (nonatomic, strong) TrainingCompany *company;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSMutableDictionary *scores;
@property (nonatomic, strong) NSMutableDictionary *scoresToDisplay;
@property (nonatomic, strong) NSMutableArray *studentsToDisplay;
@property (nonatomic, strong) NSMutableArray *students;
@property (nonatomic, strong) NSArray *tests;
@property (nonatomic, assign) NSInteger sortType;
@property (nonatomic, strong) NSString *testName;

@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableArray *fieldsFilterAdded;
@property (nonatomic, strong) NSMutableArray *fieldsFilter;
@property (nonatomic, strong) NSArray *fieldsCompany;
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSArray *switchFields;
@property (nonatomic, strong) NSArray *datePickerFieldsNames;
@property (nonatomic, strong) NSArray *pickerFields;
@property (nonatomic, strong) NSArray *requiredFields;
@property (nonatomic, strong) NSArray *numericFields;
@property (nonatomic, strong) NSMutableArray *disabledFields;
@end

@implementation CSDScoresFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Tests Filter";
    /*
    self.students = [NSMutableArray arrayWithObject:self.studentId];
    self.studentsToDisplay = [NSMutableArray arrayWithObject:self.studentId];
    self.scoresToDisplay = [NSMutableDictionary dictionary];
    [self.scoresToDisplay setObject:self.testsSCores forKey:self.studentId];
    self.scores = [NSMutableDictionary dictionary];
    [self.scores setObject:self.testsSCores forKey:self.studentId];
    */
    [self loadCurrentCompany];

    self.fields = [NSMutableArray arrayWithObjects:KeyTestName, KeyDateFrom, KeyDateTo, nil];
    self.datePickerFieldsNames = [NSArray arrayWithObjects:KeyDateFrom, KeyDateTo, nil];
    self.pickerFields = [NSArray arrayWithObjects:KeyTestName, nil];
    self.values = [NSMutableDictionary dictionary];
    self.disabledFields = [NSMutableArray array];
    self.fieldsCompany = [self getCompanyCategories];
    
    self.fieldsFilter = [NSMutableArray arrayWithArray:self.fields];
    
    if (self.fieldsCompany.count) {
        [self.fieldsFilter addObjectsFromArray:self.fieldsCompany];
    }
    
    if (DEVICE_IS_IPAD) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(closeButtonPressed:)];
        self.navigationItem.leftBarButtonItem = closeButton;
    } else {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonPressed:)];
        self.navigationItem.leftBarButtonItem = backButton;
    }

    [self.tableView setEditing:YES];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
}

-(NSArray*)getCompanyCategories {
    NSDictionary *info = [self.company getCategoriesInfo];
    //23.03.2020 return info.allKeys;
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    return [info.allValues sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
}

-(void)loadCurrentCompany{
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    TrainingCompanyAggregate *agg = (TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    self.company = [agg getTrainingCompanyWithName:userCompany];
}


-(NSString*)getCodingFieldFromName:(NSString*)name {
    // 18.03.2020 we need a way to map the "display" string to a "real" coding field
    if ([name isEqualToString:KeyFilterInstructorId]) {
        return @"instructorEmployeeId";
    }
    if ([name isEqualToString:KeyFilterDriverLicenseNumber]) {
        return @"driverLicenseNumber";
    }
    if ([name isEqualToString:KeyFilterDriverLicenseState]) {
        return @"driverLicenseState";
    }
    return nil;
}

-(IBAction)saveButtonPressed:(id)sender {
    if (!self.testName.length) {
        [self showSimpleMessage:@"Please select Test"];
        return;
    }
    if (!self.fromDate) {
        [self showSimpleMessage:@"Please select From Date"];
        return;
    }
    if (!self.toDate) {
        [self showSimpleMessage:@"Please select To Date"];
        return;
    }

    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];

    [objects addObject:self.testName];
    [keys addObject:KeyTestName];

    [objects addObject:self.fromDate];
    [keys addObject:KeyDateFrom];

    [objects addObject:self.toDate];
    [keys addObject:KeyDateTo];
    
    NSDictionary *compCategories = [self.company getCategoriesInfo];
    if (compCategories) {
        [objects addObject:compCategories];
        [keys addObject:KeyCategories];
    }
    
    for (NSString *key in self.fieldsFilter) {
        if ([self.fields containsObject:key]) {
            continue;
        } else {
            id val = [self.values objectForKey:key];
            if (val) {
                [objects addObject:val];
                [keys addObject:key];
            }
        }
    }
    
    [keys addObject:self.addDelegateKey];
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObjects:forKeys:)]) {
        [self.addDelegate didAddObjects:objects forKeys:keys];
    }
    NSLog(@"");
    
}

-(IBAction)searchButtonPressed:(id)sender {
    if (!self.fromDate) {
        [self showSimpleMessage:@"Please select From Date"];
        return;
    }
    if (!self.toDate) {
        [self showSimpleMessage:@"Please select To Date"];
        return;
    }
    
    TrainingScoreAggregate *agg = (TrainingScoreAggregate*)[self aggregate];
    [agg getScoresForStudent:self.student.employeeNumber fromDate:self.fromDate toDate:self.toDate];
}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"TrainingScore"];
}

-(void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)closeButtonPressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(void)showChartForTest:(NSString*)testName {
    NSString *studentId = [self.studentsToDisplay objectAtIndex:0];
    NSArray *scores = [self.scoresToDisplay objectForKey:studentId];

    if (testName.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"scoreTestName=%@", testName];
        scores = [scores filteredArrayUsingPredicate:predicate];
    }
    
    NSMutableArray *CSVFormats = [NSMutableArray array];
    
    NSArray *line = [NSArray arrayWithObjects:@"Date", @"Time", @"Value" , nil];

    for (NSDictionary *scoreInfo in scores) {
        NSInteger score = [[scoreInfo objectForKey:KeyScoreTotal] integerValue];
        NSString *startDateStr = [self getDateFromString:[scoreInfo objectForKey:KeyScoreStartDate]];
        NSArray *dateTime = [startDateStr componentsSeparatedByString:@" "];
        
        if (dateTime.count < 2) {
            continue;
        }
        
        NSArray *line = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", [dateTime objectAtIndex:0]], [NSString stringWithFormat:@"%@", [dateTime objectAtIndex:1]], [NSString stringWithFormat:@"%d", (int)score],nil];
        [CSVFormats addObject:[line componentsJoinedByString:@","]];

    }
    NSLog(@"");
    
}

-(IBAction)chartButtonPressed:(id)sender {
    NSArray *tests = [self getTestsNames];
    
    if (tests.count == 0) {
        [self showSimpleMessage:@"No tests available!"];
        return;
    } else if (tests.count > 1) {
        
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:@"Please select which test to show"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        for (NSString *testName in tests) {
            UIAlertAction* action = [UIAlertAction actionWithTitle:testName
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                [self showChartForTest:testName];
                                                             }];
            [al addAction:action];
        }
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                         }];
        [al addAction:cancelAction];
        [self presentViewController:al animated:YES completion:nil];
        return;
    }
    [self showChartForTest:nil];
}

-(NSArray*)getTestsNames {
    NSMutableArray *testsNames = [NSMutableArray array];
    NSString *studentId = [self.studentsToDisplay objectAtIndex:0];
    NSArray *scores = [self.scoresToDisplay objectForKey:studentId];

    for (NSDictionary *scoreInfo in scores) {
        NSString *testName = [scoreInfo objectForKey:KeyScoreTestName];
        if (testName.length) {
            if (![testsNames containsObject:testName]) {
                [testsNames addObject:testName];
            }
        }
    }
    return testsNames;
}

-(NSString*)getStudentNameForTest:(NSString*)testName {
    NSString *studentId = [self.studentsToDisplay objectAtIndex:0];
    NSArray *scores = [self.scoresToDisplay objectForKey:studentId];
    NSString *name = nil;
    if (scores.count) {
        NSDictionary *info = [scores objectAtIndex:0];
        if (testName.length) {
            name = [NSString stringWithFormat:@"%@ %@ - %@", [info objectForKey:KeyScoreStudentLastName], [info objectForKey:KeyScoreStudentFirstName], testName];
        } else {
            name = [NSString stringWithFormat:@"%@ %@ - %@", [info objectForKey:KeyScoreStudentLastName], [info objectForKey:KeyScoreStudentFirstName], [info objectForKey:KeyScoreTestName]];
        }
    }
    return name;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)showDatePickerFromView:(UIView*)fromView andKey:(NSString*)key  {
    DateSelectorViewController *controller = [[DateSelectorViewController alloc] initWithNibName:@"DateSelectorViewController"
                                                                                          bundle:nil
                                                                                        forDates:[NSArray arrayWithObject:key]];
    controller.selectDelegate = self;
    controller.shouldPopUpOnIpad = YES;
    
    NSDate *date = nil;
    NSString *title = nil;
    
    if ([key isEqualToString:KeyDateFrom]) {
        date = self.fromDate;
        title = @"From";
    } else if ([key isEqualToString:KeyDateTo]) {
        date = self.toDate;
        controller.minDate = self.fromDate;
        title = @"To";
    }
    
    if (!date) {
        date = [NSDate date];
    }
    
    controller.title = title;
    controller.isSimpleDatePicker = YES;

    controller.currentDate = date;
    
    if (DEVICE_IS_IPHONE) {
        controller.isCancelNewLogic = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self showPopoverForViewController:controller fromView:fromView];
    }
}

-(IBAction)fromDateButtonPressed:(UIBarButtonItem*)sender {
    /*
    [self showDatePickerFromButton:sender andKey:KeyDateFrom];
     */
}

-(IBAction)toDateButtonPressed:(UIBarButtonItem*)sender {
    /*
    if (!self.fromDate) {
        [self showSimpleMessage:@"Select From Date first"];
        return;
    }
    [self showDatePickerFromButton:sender andKey:KeyDateTo];
    */
}

-(IBAction)studentButtonPressed:(UIBarButtonItem*)sender {
    UserAggregate *aggregate = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];
    
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    title = @"Students";
    fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
    detailFields = nil;
    sortKey = @"surname";
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    predicate = [NSPredicate predicateWithFormat:@"company=%@", userCompany];
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:KeyStudent
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = KeyStudent;
    listController.title = title;
    listController.showClearButton = YES;
    if (self.student) {
        listController.selectedItem = self.student;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:sender];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

-(IBAction)showTestPickerFromView:(UIView*)fromView {
    if (!self.tests.count) {
        TestFormAggregate *agg = (TestFormAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestForm"];
        self.tests = [[agg getTestsNames] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    }
    NSLog(@"");
        
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:self.tests
                                                                                                forKey:KeyTestName];
    
    listController.selectDelegate = self;
    listController.title = @"Tests";
    listController.showIndex = NO;
    listController.newLogic = YES;
    if (self.testName) {
        listController.selectedValue = self.testName;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

-(void)showFieldsFilterFromView:(UIView*)fromView {
    NSArray *codingFields = [NSArray arrayWithObjects:KeyFilterInstructorFirstName, KeyFilterInstructorLastName, KeyFilterInstructorId, KeyFilterStudentFirstName, KeyFilterStudentLastName, KeyFilterDriverLicenseNumber, KeyFilterDriverLicenseState, nil];
    
    RCOValuesListViewController *listController = [[RCOValuesListViewController alloc] initWithNibName:@"RCOValuesListViewController"
                                                                                                bundle:nil
                                                                                                 items:codingFields
                                                                                                forKey:KeyFilterField];
    
    listController.selectDelegate = self;
    listController.title = @"Fields";
    listController.showIndex = NO;
    listController.newLogic = YES;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

#pragma mark UITableView methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section <= 2 ) {
        return UITableViewCellEditingStyleNone;
    } else if (indexPath.section < self.fieldsFilter.count){
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleInsert;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section <= 2 ) {
        return NO;
    }
    return YES;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * message = nil;
    message = @"Remove filter field ?";
    
    return message;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self showFieldsFilterFromView:cell];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        NSString *key = [self.fieldsFilter objectAtIndex:indexPath.section];
        [self.fieldsFilter removeObject:key];
        [self.values removeObjectForKey:key];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        [tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fieldsFilter.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < self.fieldsFilter.count) {
        return [self.fieldsFilter objectAtIndex:section];
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.fieldsFilter.count) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *key = [self.fieldsFilter objectAtIndex:indexPath.section];
        if ([key isEqualToString:KeyTestName]) {
            [self showTestPickerFromView:cell];
        } else if ([self.datePickerFieldsNames containsObject:key]) {
            [self showDatePickerFromView:cell andKey:key];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *key = nil;
    NSString *value = nil;
    BOOL requiredField = NO;
    if (indexPath.section < self.fieldsFilter.count) {
        key = [self.fieldsFilter objectAtIndex:indexPath.section];
        value = [self.values objectForKey:[NSString stringWithFormat:@"%@", key]];
        requiredField = [self.requiredFields containsObject:key];
    } else {
        value = @"Add Filter Field";
    }
    
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
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = requiredLbl;
        cell.imageView.image = [UIImage imageNamed:@"CALENDAR"];
        return cell;
        
    } else if ([self.pickerFields containsObject:key]) {
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"PickerCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PickerCell"];
        }
        
        cell.textLabel.text = value;
        cell.detailTextLabel.text = nil;
        
        if (value) {
            cell.accessoryView = nil;
        } else {
            cell.accessoryView = requiredLbl;
        }
        
        if ([self.disabledFields containsObject:key]) {
            cell.textLabel.textColor = [UIColor lightGrayColor];
        } else {
            cell.textLabel.textColor = [UIColor darkTextColor];
        }

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    
    inputCell.inputTextField.font = [UIFont systemFontOfSize:15];
    
    
    return inputCell;
}
-(NSString*)getDateFromString:(NSString*)dateStr {
    return [dateStr stringByReplacingOccurrencesOfString:@".000" withString:@""];
}

-(NSString*)getHoursFromTime:(NSString*)time {
    NSInteger minutes = [time integerValue];
    NSInteger hours = minutes/60;
    minutes = minutes %60;
    return [NSString stringWithFormat:@"%02d:%02d", (int)hours, (int)minutes];
}

-(NSString*)getScoreInfoFromDict:(NSDictionary*)scoreInfo {
    NSString *hours = [self getHoursFromTime:[scoreInfo objectForKey:KeyScoreElapsedTime]];
    
    NSString *txt = [NSString stringWithFormat:@"Test: %@ (%@)\nPoints: %@/%@\nDate: %@", [scoreInfo objectForKey:KeyScoreTestName], hours, [scoreInfo objectForKey:KeyScoreTotal], [scoreInfo objectForKey:KeyScorePointsPossible], [scoreInfo objectForKey:KeyScoreStartDate]];
    return txt;
}

#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([key isEqualToString:KeyFilterField]) {
        if (object) {
            if (![self.fieldsFilter containsObject:object]) {
                [self.fieldsFilter addObject:object];
            }
        }
    } else if ([key isEqualToString:KeyTestName]) {
        if (object) {
            self.testName = (NSString*)object;
            [self.values setObject:self.testName forKey:key];
        } else {
            self.testName = nil;
            [self.values removeObjectForKey:key];
        }
    } else if ([key isEqualToString:KeyStudent]) {
        if ([object isKindOfClass:[User class]]) {
            self.student = (User*)object;
        } else {
            self.student = nil;
        }
        if (!self.student) {
            [self.studentBtn setTitle:@"Student"];
        } else {
            [self.studentBtn setTitle:[NSString stringWithFormat:@"%@ %@", self.student.surname, self.student.firstname]];
        }
        [self sortScores];
    } else if ([key isEqualToString:KeyDateFrom]) {
        self.fromDate = (NSDate*)object;
        [self.values setObject:self.fromDate forKey:key];
    } else if ([key isEqualToString:KeyDateTo]) {
        self.toDate = (NSDate*)object;
        [self.values setObject:self.toDate forKey:key];
    }
    
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

    [self.tableView reloadData];
    
    if ([key isEqualToString:KeyFilterField]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:(self.fieldsFilter.count - 1)];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[InputCell class]]) {
            InputCell *inputCell = (InputCell*)cell;
            [inputCell.inputTextField becomeFirstResponder];
        }
    }
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:STG]) {
        NSLog(@"");
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag < self.fieldsFilter.count) {
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)textFieldChanged:(UITextField*) textField {
    NSString *value = textField.text;
    NSString *key = nil;

    key = [self.fieldsFilter objectAtIndex:textField.tag];

    [self.values setObject:[value stringByReplacingOccurrencesOfString:@"\n" withString:@" "] forKey:key];
}

-(IBAction)sortScoresChanged:(UISegmentedControl*)sender {
    self.sortType = sender.selectedSegmentIndex;
    [self sortScores];
    [self.tableView reloadData];
}

-(void)sortScores {
    NSString *sortKey = nil;
    if (self.sortType == SortTypeName) {
        sortKey = KeyScoreTestName;
    } else if (self.sortType == SortTypeScore) {
        sortKey = KeyScoreTotal;
    } else if (self.sortType == SortTypeDate) {
        sortKey = KeyScoreStartDate;
    } else {
        return;
    }
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES];
    NSMutableArray *predicates = [NSMutableArray array];
    
    if (self.student.employeeNumber.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@", KeyScoreStudentId, self.student.employeeNumber];
        [predicates addObject:predicate];
        self.studentsToDisplay = [NSMutableArray arrayWithObject:self.student.employeeNumber];
    } else {
        self.studentsToDisplay = [NSMutableArray arrayWithArray:self.students];
    }
    if (self.testName.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@", KeyScoreTestName, self.testName];
        [predicates addObject:predicate];
    }
    self.scoresToDisplay = [NSMutableDictionary dictionary];
    
    for (NSString *key in self.studentsToDisplay) {
        NSArray *arr = [self.scores objectForKey:key];
        if (predicates.count) {
            arr = [arr filteredArrayUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
        }
        [self.scoresToDisplay setObject:[arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]] forKey:key];
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
    if (self.currentIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
