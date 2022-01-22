//
//  CSDScoresViewController.m
//  CSD
//
//  Created by .D. .D. on 12/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDScoresViewController.h"
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
#import "CSDScoresDetailsViewController.h"
#import "FilterWithOptionsViewController.h"
#import "CSDScoreCell.h"
#import "TrainingTestInfo+CoreDataClass.h"
#import "CSDScoresFilterViewController.h"

#define KeyDateFrom @"fromDate"
#define KeyDateTo @"toDate"
#define KeyStudent @"student"
#define KeyTestName @"testName"
#define Key_Filter @"keyFilter"

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
#define KeyScoreTestBarcode @"scoreTestBarcode"

#define SortTypeName 0
#define SortTypeHours 1

#define TrendUp 1
#define TrendDown -1
#define TrendSame 0

#define TestsAll @"All Tests"

@interface CSDScoresViewController ()
@property (nonatomic, strong) TrainingCompany *company;
@property (nonatomic, strong) User *student;

@property (nonatomic, strong) NSMutableDictionary *scores;
@property (nonatomic, strong) NSMutableDictionary *scoresToDisplay;
@property (nonatomic, strong) NSMutableArray *hours;
@property (nonatomic, strong) NSMutableArray *students;
@property (nonatomic, strong) NSMutableArray *studentsToDisplay;
@property (nonatomic, strong) NSMutableArray *tests;
@property (nonatomic, assign) NSInteger sortType;
@property (nonatomic, strong) NSString *testName;
@property (nonatomic, strong) UIBarButtonItem *searchBtn;

// Date Filter
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSDate *customDate;
@property (nonatomic, strong) NSString *dateOption;
@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation CSDScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Scores";
    self.dateOption = DateString_ThisWeek;

    NSDictionary *startEndDate = [NSDate getStartEndIntervalsForOption:self.dateOption];
    self.fromDate = [startEndDate objectForKey:StartDate];
    self.toDate = [startEndDate objectForKey:EndDate];

    self.searchBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                   target:self
                                                                   action:@selector(searchButtonPressed:)];
    [self.searchBtn setEnabled:NO];
    self.sortType = 0;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:self.searchBtn];
    [self loadCurrentCompany];
    self.isFirstLoad = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstLoad && self.dateOption.length) {
        [self.searchBtn setEnabled:YES];
        [self searchButtonPressed:nil];
        self.isFirstLoad = NO;
    }
}

-(void)loadCurrentCompany{
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    TrainingCompanyAggregate *agg = (TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    self.company = [agg getTrainingCompanyWithName:userCompany];
}

-(void)showLoading {
    self.progressHUD.labelText = @"Getting scores...";
    
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
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
    [self showLoading];
    [self performSelector:@selector(searchSores) withObject:nil afterDelay:0.1];
}

-(void)searchSores {
    TrainingScoreAggregate *agg = (TrainingScoreAggregate*)[self aggregate];
    [agg getScoresForStudent:self.student.employeeNumber fromDate:self.fromDate toDate:self.toDate];
    [self.searchBtn setEnabled:NO];
}

-(IBAction)filterButtonPressedNew:(id)sender {
    CSDScoresFilterViewController *controller = [[CSDScoresFilterViewController alloc] initWithNibName:@"CSDScoresFilterViewController"
                                                                                            bundle:nil];
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:controller fromBarButton:sender];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(IBAction)filterButtonPressed:(id)sender {
}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"TrainingScore"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)showDatePickerFromButton:(UIBarButtonItem*)fromBtn andKey:(NSString*)key  {
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
        [self showPopoverForViewController:controller fromBarButton:fromBtn];
    }
}

-(IBAction)fromDateButtonPressed:(UIBarButtonItem*)sender {
    [self showDatePickerFromButton:sender andKey:KeyDateFrom];
}

-(IBAction)toDateButtonPressed:(UIBarButtonItem*)sender {
    if (!self.fromDate) {
        [self showSimpleMessage:@"Select From Date first"];
        return;
    }
    [self showDatePickerFromButton:sender andKey:KeyDateTo];
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

-(IBAction)testButtonPressed:(UIBarButtonItem*)sender {
    if (!self.tests.count) {
        TestFormAggregate *agg = (TestFormAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestForm"];
        NSArray *tsts = [[agg getTestsNames] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
        self.tests = [NSMutableArray arrayWithArray:tsts];
        [self.tests addObject:TestsAll];
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
    } else {
        listController.selectedValue = TestsAll;
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:sender];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hours.count + 1;
    return self.studentsToDisplay.count + 1;
    return 1;
    
    NSString *studentId = [self.studentsToDisplay objectAtIndex:section];
    NSArray *scores = [self.scoresToDisplay objectForKey:studentId];

    return scores.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    return self.studentsToDisplay.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.testName.length || self.customDate || self.student || self.dateOption) {
        NSMutableArray *arr = [NSMutableArray array];
        if (self.dateOption.length) {
            [arr addObject:self.dateOption];
        } else if (self.customDate) {
            [arr addObject:[[self aggregate] rcoDateToString:self.customDate]];
        }
        if (self.testName.length) {
            [arr addObject:[NSString stringWithFormat:@"Test: %@", self.testName]];
        }
        if (self.student) {
            [arr addObject:[self.student Name]];
        }
        return [NSString stringWithFormat:@"Filter: %@", [arr componentsJoinedByString:@", "]];
    }
    return @"Filter Options: None";
    
    NSString *studentId = [self.studentsToDisplay objectAtIndex:section];
    NSDictionary *studentInfo = [self.scoresToDisplay objectForKey:studentId];
    return [NSString stringWithFormat:@"%@ %@", [studentInfo objectForKey:KeyScoreStudentLastName],[studentInfo objectForKey:KeyScoreStudentFirstName]];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSDScoreCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"CSDScoreCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CSDScoreCell"
                                                     owner:self
                                                   options:nil];
        cell = (CSDScoreCell *)[nib objectAtIndex:0];
    }

    cell.firstNameLabel.layer.borderWidth = 1;
    cell.firstNameLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.lastNameLabel.layer.borderWidth = 1;
    cell.lastNameLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.scoreLabel.layer.borderWidth = 1;
    cell.scoreLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.statusLabel.layer.borderWidth = 1;
    cell.statusLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.statusImage.layer.borderWidth = 1;
    cell.statusImage.layer.borderColor = [UIColor blackColor].CGColor;

    
    NSString *firstName = @"First Name";
    NSString *lastName = @"Last Name";
    NSString *hours = @"Hours";
    NSString *status = @"Status";
    UIFont *font = [UIFont boldSystemFontOfSize:17];
    UIColor *bgColor = nil;

    if (indexPath.row > 0) {
        /*
        NSString *studentId = [self.studentsToDisplay objectAtIndex:(indexPath.row - 1)];
        NSDictionary *scoreInfo = [self.scoresToDisplay objectForKey:studentId];
        firstName = [scoreInfo objectForKey:KeyScoreStudentFirstName];
        lastName = [scoreInfo objectForKey:KeyScoreStudentLastName];
        NSString *timeElapsed = [scoreInfo objectForKey:KeyScoreElapsedTime];
        hours = [self getHoursFromTime:timeElapsed];
        font = [UIFont systemFontOfSize:17];
        [cell.discolureBtn setHidden:NO];
        bgColor = [UIColor whiteColor];
        */
        NSDictionary *scoreInfo = [self.hours objectAtIndex:(indexPath.row - 1)];
        firstName = [scoreInfo objectForKey:KeyScoreStudentFirstName];
        lastName = [scoreInfo objectForKey:KeyScoreStudentLastName];
        NSString *timeElapsed = [scoreInfo objectForKey:KeyScoreElapsedTime];
        hours = [self getHoursFromTime:timeElapsed];
        status = @"";
        NSString *studentId = [scoreInfo objectForKey:KeyScoreStudentId];
        NSInteger trend = [self getTrendForStudent:studentId];
        cell.statusImage.image = [self getImageForTrend:trend];
        font = [UIFont systemFontOfSize:17];
        [cell.discolureBtn setHidden:NO];
        bgColor = [UIColor whiteColor];
        cell.statusImage.backgroundColor = [UIColor whiteColor];
    } else {
        [cell.discolureBtn setHidden:YES];
        bgColor = [TrainingTestInfo lightColor];
        cell.statusImage.image = nil;
        cell.statusImage.backgroundColor = [UIColor clearColor];
    }
    
    cell.firstNameLabel.text = firstName;
    cell.firstNameLabel.font = font;
    cell.firstNameLabel.backgroundColor = bgColor;
    cell.lastNameLabel.text = lastName;
    cell.lastNameLabel.font = font;
    cell.lastNameLabel.backgroundColor = bgColor;
    cell.scoreLabel.text = hours;
    cell.scoreLabel.font = font;
    cell.scoreLabel.backgroundColor = bgColor;
    cell.statusLabel.text = status;
    cell.statusLabel.font = font;
    cell.statusLabel.backgroundColor = bgColor;
    
    /*
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"simpleCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simpleCell"];
    }
    
    NSString *studentId = [self.studentsToDisplay objectAtIndex:indexPath.section];
    NSDictionary *scoreInfo = [self.scoresToDisplay objectForKey:studentId];
    cell.textLabel.text = [self getScoreInfoFromDict:scoreInfo];
    [cell.textLabel setNumberOfLines:3];
    */
    return cell;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return nil;
    }
    return indexPath;
}

-(UIImage*)getImageForTrend:(NSInteger)trend {
    switch (trend) {
        case TrendUp:
            return [UIImage imageNamed:@"trendUp"];
        case TrendDown:
            return [UIImage imageNamed:@"trendDown"];
        case TrendSame:
            return [UIImage imageNamed:@"trendSame"];
    }
    return nil;
}

-(NSInteger)getTrendForStudent:(NSString*)studentId {
    NSArray *tests = [self.scores objectForKey:studentId];
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"scoreTestName" ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"scoreEndDate" ascending:YES];

    tests = [tests sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd1, sd2, nil]];
    if ((tests.count == 1) || (tests.count == 0)) {
        return TrendSame;
    } else {
        NSInteger index = tests.count - 1;
        NSDictionary *last = [tests objectAtIndex:index];
        NSDictionary *last1 = [tests objectAtIndex:(index-1)];
        NSInteger s1 = [[last objectForKey:@"scoreTotal"] integerValue];
        NSInteger s2 = [[last1 objectForKey:@"scoreTotal"] integerValue];
        if (s1 > s2) {
            return TrendUp;
        } else if (s1 == s2) {
            return TrendSame;
        } else {
            return TrendDown;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row - 1;
    NSDictionary *dict = [self.hours objectAtIndex:index];
    NSString *studentId = [dict objectForKey:KeyScoreStudentId];
    
    NSArray *scores = [self.scores objectForKey:studentId];
    if ([self testPredicate]) {
        scores = [scores filteredArrayUsingPredicate:[self testPredicate]];
    }
    CSDScoresDetailsViewController *detail = [[CSDScoresDetailsViewController alloc] initWithNibName:@"CSDScoresDetailsViewController" bundle:nil];
    detail.testsSCores = scores;
    detail.studentId = studentId;
    [self.navigationController pushViewController:detail animated:YES];
}

-(NSString*)getHoursFromTime:(NSString*)time {
    NSInteger minutes = [time integerValue];
    NSInteger hours = minutes/60;
    minutes = minutes %60;
    return [NSString stringWithFormat:@"%02d:%02d", (int)hours, (int)minutes];
}

-(NSString*)getScoreInfoFromDict:(NSDictionary*)scoreInfo {
    NSString *txt = [NSString stringWithFormat:@"Points: %@\nTime: %@",[scoreInfo objectForKey:KeyScoreTotal], [scoreInfo objectForKey:KeyScoreElapsedTime]];
    return txt;
}

-(void)filterItems {
    self.filterPredicate = nil;
    if (self.fromDate && self.toDate) {
        self.filterPredicate = [NSPredicate predicateWithFormat:@"dateTime >=%@ and dateTime <=%@", self.fromDate, self.toDate];
    }
/*
    if (self.filterPredicate) {
        self.itemsFiltered = [NSMutableArray arrayWithArray:[self.items filteredArrayUsingPredicate:self.filterPredicate]];
    } else {
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    }

    [self groupItems];
 */
  if (self.filterPredicate) {
        self.filterButton.image = [UIImage imageNamed:@"filter-icon_Remove"];
    } else {
        self.filterButton.image = [UIImage imageNamed:@"filter-icon"];
    }
}


#pragma mark AddObject delegate

-(void)didAddObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    
    NSString *key = nil;
    
    for (NSInteger i = 0; i < keys.count; i++) {
        key = [keys objectAtIndex:i];
        id obj = [objects objectAtIndex:i];
        
        if ([obj isKindOfClass:[NSDate class]]) {
            // is a custom date
            self.customDate = (NSDate*)obj;
            
            self.fromDate = [self.customDate dateAsDateWithoutTime];
            self.toDate = self.fromDate;
            
        } else if ([obj isKindOfClass:[NSString class]] && [[NSDate dateOptions] containsObject:obj]) {
            NSLog(@"");
            self.dateOption = (NSString*)obj;
            
            NSDictionary *startEndDate = [NSDate getStartEndIntervalsForOption:self.dateOption];
            self.fromDate = [startEndDate objectForKey:StartDate];
            self.toDate = [startEndDate objectForKey:EndDate];
        } else {
            // todo a way of
            NSLog(@"");
        }
        [self.searchBtn setEnabled:YES];
        [self searchButtonPressed:nil];
    }
    
    if (objects && !objects.count && keys) {
        // remove filter
        self.fromDate = nil;
        self.toDate = nil;
        self.filterPredicate = nil;
    }
    
    [self filterItems];

    [self.tableView reloadData];

    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

    [self.tableView reloadData];
}


-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([key isEqualToString:KeyTestName]) {
        if (object) {
            NSString *name = (NSString*)object;;
            if ([name isEqualToString:TestsAll]) {
                self.testName = nil;
                [self.testBtn setTitle:@"Test"];
            } else {
                self.testName = name;
                [self.testBtn setTitle:[NSString stringWithFormat:@"%@", self.testName]];
            }
        } else {
            self.testName = nil;
            [self.testBtn setTitle:@"Test"];
        }
        [self sortScores];
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
        NSString *title = nil;
        if (self.fromDate) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            title = [NSString stringWithFormat:@"From:%@", [dateFormat stringFromDate:self.fromDate]];
        } else {
            title = @"From";
        }
        [self.fromBtn setTitle:title];
    } else if ([key isEqualToString:KeyDateTo]) {
        self.toDate = (NSDate*)object;
        NSString *title = nil;
        if (self.toDate) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            title = [NSString stringWithFormat:@"To:%@", [dateFormat stringFromDate:self.toDate]];
        } else {
            title = @"To";
        }
        [self.toBtn setTitle:title];
    }
    
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

    [self.tableView reloadData];
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {

    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:STG]) {
        NSArray *values = [messageInfo objectForKey:RESPONSE_OBJ];
        NSArray *keys = [NSArray arrayWithObjects:KeyScoreOrgNumber, KeyScoreStudentFirstName, KeyScoreStudentLastName, KeyScoreStudentId, KeyScoreTestName, KeyScoreStartDate, KeyScoreEndDate, KeyScoreElapsedTime, KeyScorePointsPossible, KeyScoreTotal, KeyScoreTestBarcode, nil];
        NSLog(@"");
        self.scores = [NSMutableDictionary dictionary];
        self.scoresToDisplay = [NSMutableDictionary dictionary];
        self.students = [NSMutableArray array];
        self.studentsToDisplay = [NSMutableArray array];
        self.hours = [NSMutableArray array];
        
        if (!values.count) {
            [self showSimpleMessage:@"No scores found for this interval"];
        }
        
        for (NSArray *arr in values) {
            NSString *studentId = nil;
            NSString *studentLastName = nil;
            NSMutableDictionary *scoreForStudent = [NSMutableDictionary dictionary];
            NSString *minutes = nil;
            
            for (NSInteger i = 0; i < arr.count; i++) {
                NSString *key = [keys objectAtIndex:i];
                NSString *val = [arr objectAtIndex:i];
                
                if ([key isEqualToString:KeyScoreStudentId]) {
                    studentId = val;
                }
                if ([key isEqualToString:KeyScoreStudentLastName]) {
                    studentLastName = val;
                }

                if ([key isEqualToString:KeyScoreElapsedTime]) {
                    minutes = val;
                }
                
                if (!val) {
                    val = @"";
                }
                [scoreForStudent setObject:val forKey:key];
            }

            NSString *studentKey = [NSString stringWithFormat:@"%@", studentId];

            if (!self.students) {
                self.students = [NSMutableArray array];
            }
            if (![self.students containsObject:studentKey]) {
                [self.students addObject:studentKey];
            }
            
            NSMutableArray *userScores = [self.scores objectForKey:studentKey];
            if (!userScores) {
                userScores = [NSMutableArray array];
            }
            [userScores addObject:scoreForStudent];
            [self.scores setObject:userScores forKey:studentKey];
        }
        [self sortScores];
        [self.tableView reloadData];
        [self.progressHUD hide:YES];
    }
}

-(NSPredicate*)testPredicate {
    if (self.testName.length) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"scoreTestName=%@", self.testName];
        return pred;
    } else {
        return nil;
    }
}

-(void)loadHours {
    self.hours = [NSMutableArray array];
    
    for (NSString *key in self.scores.allKeys) {
        NSArray *scores = [self.scores objectForKey:key];
        if ([self testPredicate]) {
            scores = [scores filteredArrayUsingPredicate:[self testPredicate]];
        }
        NSMutableDictionary *hoursDict = [NSMutableDictionary dictionary];
        NSString *lastName = nil;
        NSString *firstName = nil;
        NSString *studentId = nil;
        NSInteger minutes = 0;
        for (NSDictionary *dict in scores) {
            lastName = [dict objectForKey:KeyScoreStudentLastName];
            firstName = [dict objectForKey:KeyScoreStudentFirstName];
            studentId = [dict objectForKey:KeyScoreStudentId];
            minutes += [[dict objectForKey:KeyScoreElapsedTime] integerValue];
        }
        if (studentId.length) {
            [hoursDict setObject:[NSNumber numberWithInteger:minutes] forKey:KeyScoreElapsedTime];
            [hoursDict setObject:lastName forKey:KeyScoreStudentLastName];
            [hoursDict setObject:firstName forKey:KeyScoreStudentFirstName];
            [hoursDict setObject:studentId forKey:KeyScoreStudentId];
            [self.hours addObject:hoursDict];
        }
    }
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:STG]) {
        NSLog(@"");
        [self.progressHUD hide:YES];
    }
}

-(IBAction)sortScoresChanged:(UISegmentedControl*)sender {
    self.sortType = sender.selectedSegmentIndex;
    [self sortScores];
    [self.tableView reloadData];
}

-(void)sortScores {
    NSString *sortKey = nil;
    [self loadHours];
    
    if (self.sortType == SortTypeName) {
        self.studentsToDisplay = [NSMutableArray arrayWithArray:[self.students sortedArrayUsingSelector:@selector(compare:)]];
        sortKey = KeyScoreStudentLastName;
    } else if (self.sortType == SortTypeHours) {
        sortKey = KeyScoreElapsedTime;
    } else {
        return;
    }
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES];
    self.hours = [NSMutableArray arrayWithArray:[self.hours sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
/*
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
        arr = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
        double score = 0;
        double timeElapsed = 0;
        NSString *firstName = nil;
        NSString *lastName = nil;
        
        for (NSDictionary *dict in arr) {
            score += [[dict objectForKey:KeyScoreTotal] doubleValue];
            timeElapsed += [[dict objectForKey:KeyScoreElapsedTime] doubleValue];
            firstName = [dict objectForKey:KeyScoreStudentFirstName];
            lastName = [dict objectForKey:KeyScoreStudentLastName];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithDouble:score] forKey:KeyScoreTotal];
        [dict setObject:[NSNumber numberWithDouble:timeElapsed] forKey:KeyScoreElapsedTime];
        [dict setObject:firstName forKey:KeyScoreStudentFirstName];
        [dict setObject:lastName forKey:KeyScoreStudentLastName];

        [self.scoresToDisplay setObject:dict forKey:key];
    }
    */
}

@end
