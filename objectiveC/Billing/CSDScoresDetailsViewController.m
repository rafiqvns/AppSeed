//
//  CSDScoresDetailsViewController.m
//  CSD
//
//  Created by .D. .D. on 12/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDScoresDetailsViewController.h"
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

#define KeyDateFrom @"fromDate"
#define KeyDateTo @"toDate"
#define KeyStudent @"student"
#define KeyTestName @"testName"
#define KEY_Chart @"chart"

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

@interface CSDScoresDetailsViewController ()
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

@end

@implementation CSDScoresDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Tests scores";
    self.students = [NSMutableArray arrayWithObject:self.studentId];
    self.studentsToDisplay = [NSMutableArray arrayWithObject:self.studentId];
    self.scoresToDisplay = [NSMutableDictionary dictionary];
    [self.scoresToDisplay setObject:self.testsSCores forKey:self.studentId];
    self.scores = [NSMutableDictionary dictionary];
    [self.scores setObject:self.testsSCores forKey:self.studentId];

    [self loadCurrentCompany];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backButton;

}

-(void)loadCurrentCompany{
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    TrainingCompanyAggregate *agg = (TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    self.company = [agg getTrainingCompanyWithName:userCompany];
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
        [self showPopoverForViewController:listController fromBarButton:sender];
    } else {
        [self.navigationController pushViewController:listController animated:YES];
    }
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *studentId = [self.studentsToDisplay objectAtIndex:section];
    NSArray *scores = [self.scoresToDisplay objectForKey:studentId];

    return scores.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.studentsToDisplay.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *studentId = [self.studentsToDisplay objectAtIndex:section];
    NSArray *scores = [self.scoresToDisplay objectForKey:studentId];
    NSDictionary *studentInfo = [scores objectAtIndex:0];
    return [NSString stringWithFormat:@"%@ %@", [studentInfo objectForKey:KeyScoreStudentLastName],[studentInfo objectForKey:KeyScoreStudentFirstName]];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CSDScoreDetailCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"CSDScoreDetailCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CSDScoreDetailCell"
                                                     owner:self
                                                   options:nil];
        cell = (CSDScoreDetailCell *)[nib objectAtIndex:0];
    }

    NSString *testName = @"Test Name";
    NSString *duration = @"Hours";
    NSString *score = @"Score";
    NSString *startDate = @"Start Date";
    NSString *studentId = [self.studentsToDisplay objectAtIndex:indexPath.section];
    NSArray *scores = [self.scoresToDisplay objectForKey:studentId];
    UIFont *font = [UIFont boldSystemFontOfSize:17];
    UIColor *bgColor = nil;

    if (indexPath.row > 0) {
        NSInteger index = indexPath.row - 1;
        NSDictionary *scoreInfo = [scores objectAtIndex:index];
        testName = [scoreInfo objectForKey:KeyScoreTestName];
        duration = [self getHoursFromTime:[scoreInfo objectForKey:KeyScoreElapsedTime]];
        score = [NSString stringWithFormat:@"%@/%@", [scoreInfo objectForKey:KeyScoreTotal], [scoreInfo objectForKey:KeyScorePointsPossible]];
        startDate = [self getDateFromString:[scoreInfo objectForKey:KeyScoreStartDate]];
        font = [UIFont systemFontOfSize:17];
        bgColor = [UIColor whiteColor];
    } else {
        bgColor = [TrainingTestInfo lightColor];
    }

    cell.testNameLabel.layer.borderWidth = 1;
    cell.testNameLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.testNameLabel.text = testName;
    cell.testNameLabel.font = font;
    cell.testNameLabel.backgroundColor = bgColor;

    cell.durationNameLabel.layer.borderWidth = 1;
    cell.durationNameLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.durationNameLabel.text = duration;
    cell.durationNameLabel.font = font;
    cell.durationNameLabel.backgroundColor = bgColor;

    cell.scoreLabel.layer.borderWidth = 1;
    cell.scoreLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.scoreLabel.text = score;
    cell.scoreLabel.font = font;
    cell.scoreLabel.backgroundColor = bgColor;

    cell.dateLabel.layer.borderWidth = 1;
    cell.dateLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.dateLabel.text = startDate;
    cell.dateLabel.font = font;
    cell.dateLabel.backgroundColor = bgColor;
    
    return cell;
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
    if ([key isEqualToString:KeyTestName]) {
        if (object) {
            self.testName = (NSString*)object;
        } else {
            self.testName = nil;
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
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    if ([message isEqualToString:STG]) {
        NSLog(@"");
    }
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

@end
