//
//  CSDDashboardViewController.m
//  CSD
//
//  Created by .D. .D. on 12/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDDashboardViewController.h"
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
#import "TrainingTestInfo+CoreDataClass.h"
#import "CSDScoresFilterViewController.h"
#import "TestDataHeaderAggregate.h"

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

#define AnalyticsAccidents @"Accidents"
#define AnalyticsFatilities @"Fatilities"
#define AnalyticsDeliveries @"Deliveries"
#define AnalyticsPickups @"Pickups"
#define AnalyticsStudents @"Students"
#define AnalyticsTraining @"Training"


@interface CSDDashboardViewController ()
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
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableDictionary *values;


// Date Filter
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSDate *customDate;
@property (nonatomic, strong) NSString *dateOption;
@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, assign) BOOL isFirstLoad;


@end

@implementation CSDDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Dashboard";
    self.dateOption = DateString_ThisWeek;

    self.values = [NSMutableDictionary dictionary];
    
    NSDictionary *startEndDate = [NSDate getStartEndIntervalsForOption:self.dateOption];
    self.fromDate = [startEndDate objectForKey:StartDate];
    self.toDate = [startEndDate objectForKey:EndDate];

    self.searchBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                   target:self
                                                                   action:@selector(searchButtonPressed:)];
    [self.searchBtn setEnabled:NO];
    self.sortType = 0;
    //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:self.searchBtn];
    [self loadCurrentCompany];
    self.isFirstLoad = YES;
    self.items = [NSArray arrayWithObjects:AnalyticsAccidents, AnalyticsFatilities, AnalyticsDeliveries, AnalyticsPickups, AnalyticsStudents, AnalyticsTraining, nil];
    [self loadButtons];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstLoad && self.dateOption.length) {
        [self.searchBtn setEnabled:YES];
        [self searchButtonPressed:nil];
        self.isFirstLoad = NO;
    }
}


-(void)loadButtons {
    UIColor *start = [UIColor colorWithRed:223.0/255.0 green:240.0/255.0 blue:218.0/255.0 alpha:1];
    UIColor *end = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];
    

    for (UIButton *view in self.view.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            CAGradientLayer *layer = [[CAGradientLayer alloc] init];
            layer.frame = view.bounds;
            //layer.colors = [NSArray arrayWithObjects:(id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor, nil];
            layer.colors = [NSArray arrayWithObjects:(id)start.CGColor, (id)end.CGColor, nil];

            layer.startPoint = CGPointMake(0, 1);
            layer.endPoint = CGPointMake(1, 1);

            [view.layer insertSublayer:layer atIndex:0];
            view.layer.borderColor = [UIColor lightGrayColor].CGColor;
            view.layer.borderWidth = 2;
            view.layer.cornerRadius = 3;
            
            NSInteger index = view.tag -1 ;
            NSString *title = nil;

            if (index < self.items.count) {
                NSString *key = [self.items objectAtIndex:index];
                NSString *val = [self.values objectForKey:key];
                                if (val) {
                    title = [NSString stringWithFormat:@"%@\n%@", key, val];
                } else {
                    title = key;
                }
            }
            [view.titleLabel setNumberOfLines:2];
            [view setTitle:title forState:UIControlStateNormal];
        }
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
    [self getAnalyticsAccidents];
    [self getAnalyticsFaitilies];
    [self getAnalyticsDeliveries];
    [self getAnalyticsPickups];
    [self getAnalyticsStudents];
    [self getAnalyticsTrainingHours];
}

-(void)getAnalyticsAccidents {
    TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"];
    [agg registerForCallback:self];
    NSArray *groupCodingFields = @[@"Organization Number"];
    NSArray *addCodingFieldNames = @[@"objectid$"];
    NSArray *operations = @[@"COUNT"];
    NSDate *fromDate = nil;
    NSDate *toDate = nil;
    NSArray *filterFields = @[@"Year"];
    NSArray *filterValues = @[@"2020"];

    [agg getRecordAnalyticsAndGroupByCodingFields:groupCodingFields
                             addCodingFieldsNames:addCodingFieldNames
                                   withOperations:operations
                                         fromDate:fromDate
                                           toDate:toDate
                                   dateRangeField:nil
                                     filterFields:filterFields
                                     filterValues:filterValues
                                    filterCompOps:@"="
                                   namesDelimiter:nil
                                  valuesDelimiter:nil
                                    forRecordType:@"Accident Vehicle Report"
                                  andAnaliticType:AnalyticsAccidents];
}

-(void)getAnalyticsFaitilies {
    TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"];
    [agg registerForCallback:self];
    NSArray *groupCodingFields = @[@"Year"];
    NSArray *addCodingFieldNames = @[@"objectid$, Any fatalities"];
    NSArray *operations = @[@"COUNT", @"SUM"];

    NSDate *fromDate = [NSDate dateFromComponents:2020 month:1 day:1];
    NSDate *toDate = [NSDate dateFromComponents:2020 month:12 day:31];;

    NSArray *filterFields = nil;
    NSArray *filterValues = nil;

    [agg getRecordAnalyticsAndGroupByCodingFields:groupCodingFields
                             addCodingFieldsNames:addCodingFieldNames
                                   withOperations:operations
                                         fromDate:fromDate
                                           toDate:toDate
                                   dateRangeField:@"DateTime"
                                     filterFields:filterFields
                                     filterValues:filterValues
                                    filterCompOps:nil
                                   namesDelimiter:nil
                                  valuesDelimiter:nil
                                    forRecordType:@"Accident Vehicle Report"
                                  andAnaliticType:AnalyticsFatilities];
}
-(void)getAnalyticsTrainingHours {
    TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"];
    [agg registerForCallback:self];
    NSArray *groupCodingFields = @[@"Organization Number"];
    NSArray *addCodingFieldNames = @[@"objectid$"];
    //NSArray *operations = @[@"COUNT"];
    NSArray *operations = @[@"SUM"];

    NSDate *fromDate = nil;
    NSDate *toDate = nil;

    NSArray *filterFields = nil;
    NSArray *filterValues = nil;

    [agg getRecordAnalyticsAndGroupByCodingFields:groupCodingFields
                             addCodingFieldsNames:addCodingFieldNames
                                   withOperations:operations
                                         fromDate:fromDate
                                           toDate:toDate
                                   dateRangeField:nil
                                     filterFields:filterFields
                                     filterValues:filterValues
                                    filterCompOps:nil
                                   namesDelimiter:nil
                                  valuesDelimiter:nil
                                    forRecordType:@"Training Test Info"
                                  andAnaliticType:AnalyticsTraining];
}


-(void)getAnalyticsDeliveries {
    TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"];
    [agg registerForCallback:self];
    NSArray *groupCodingFields = @[@"Organization Number"];
    NSArray *addCodingFieldNames = @[@"objectid$"];
    NSArray *operations = @[@"COUNT"];

    NSDate *fromDate = nil;
    NSDate *toDate = nil;

    NSArray *filterFields = @[@"ItemType"];
    filterFields = @[@"Route Type"];
    NSArray *filterValues = @[@"delivery"];

    [agg getRecordAnalyticsAndGroupByCodingFields:groupCodingFields
                             addCodingFieldsNames:addCodingFieldNames
                                   withOperations:operations
                                         fromDate:fromDate
                                           toDate:toDate
                                   dateRangeField:@"DateTime"
                                     filterFields:filterFields
                                     filterValues:filterValues
                                    filterCompOps:@"="
                                   namesDelimiter:nil
                                  valuesDelimiter:nil
                                    forRecordType:/*@"Truck Route Header"*/@"Truck Route Detail"
                                  andAnaliticType:AnalyticsDeliveries];
}

-(void)getAnalyticsPickups {
    TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"];
    [agg registerForCallback:self];
    NSArray *groupCodingFields = @[@"Organization Number"];
    NSArray *addCodingFieldNames = @[@"objectid$"];
    NSArray *operations = @[@"COUNT"];

    NSDate *fromDate = nil;
    NSDate *toDate = nil;

    NSArray *filterFields = @[@"ItemType"];
    filterFields = @[@"Route Type"];
    NSArray *filterValues = @[@"pickup"];

    [agg getRecordAnalyticsAndGroupByCodingFields:groupCodingFields
                             addCodingFieldsNames:addCodingFieldNames
                                   withOperations:operations
                                         fromDate:fromDate
                                           toDate:toDate
                                   dateRangeField:@"DateTime"
                                     filterFields:filterFields
                                     filterValues:filterValues
                                    filterCompOps:@"="
                                   namesDelimiter:nil
                                  valuesDelimiter:nil
                                    forRecordType:/*@"Truck Route Header"*/@"Truck Route Detail"
                                  andAnaliticType:AnalyticsPickups];
}

-(void)getAnalyticsStudents {
    TestDataHeaderAggregate *agg = (TestDataHeaderAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"];
    [agg registerForCallback:self];
    NSArray *groupCodingFields = @[@"Organization Number"];
    NSArray *addCodingFieldNames = @[@"objectid$"];
    NSArray *operations = @[@"COUNT"];

    NSDate *fromDate = nil;
    NSDate *toDate = nil;

    NSArray *filterFields = @[@"UserType"];
    NSArray *filterValues = @[@"student"];

    [agg getRecordAnalyticsAndGroupByCodingFields:groupCodingFields
                             addCodingFieldsNames:addCodingFieldNames
                                   withOperations:operations
                                         fromDate:fromDate
                                           toDate:toDate
                                   dateRangeField:nil
                                     filterFields:filterFields
                                     filterValues:filterValues
                                    filterCompOps:@"="
                                   namesDelimiter:nil
                                  valuesDelimiter:nil
                                    forRecordType:@"User"
                                  andAnaliticType:AnalyticsStudents];
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
    return self.items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"simpleCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"simpleCell"];
    }

    NSString *txt = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = txt;
    NSString *value = [self.values objectForKey:txt];
    if (!value.length) {
        value = @"Not set";
    }
    cell.detailTextLabel.text = value;
    cell.imageView.image = [self getImageForKey:txt];
    
    return cell;
}

-(UIImage*)getImageForKey:(NSString*)key {
    if ([key isEqualToString:AnalyticsAccidents]) {
        return [UIImage imageNamed:@"DashAccidents.png"];
    }
    if ([key isEqualToString:AnalyticsDeliveries]) {
        //return [UIImage imageNamed:@"DashDeliveries.png"];
        return [UIImage imageNamed:@"DashPickup.png"];
    }
    if ([key isEqualToString:AnalyticsPickups]) {
        //return [UIImage imageNamed:@"DashDeliveries.png"];
        return [UIImage imageNamed:@"DashPickup.png"];
    }
    if ([key isEqualToString:AnalyticsFatilities]) {
        return [UIImage imageNamed:@"DashFatalities.jpeg"];
    }
    if ([key isEqualToString:AnalyticsTraining]) {
        return [UIImage imageNamed:@"DashHours.jpeg"];
    }
    if ([key isEqualToString:AnalyticsStudents]) {
        return [UIImage imageNamed:@"DashStudent.png"];
    }
    return nil;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(NSString*)getHoursFromTime:(NSString*)time {
    NSInteger minutes = [time integerValue];
    NSInteger hours = minutes/60;
    minutes = minutes %60;
    return [NSString stringWithFormat:@"%02d:%02d", (int)hours, (int)minutes];
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
}

-(void)loadHours {
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
}

-(IBAction)sortScoresChanged:(UISegmentedControl*)sender {
    self.sortType = sender.selectedSegmentIndex;
    [self sortScores];
    [self.tableView reloadData];
}

-(void)sortScores {
}

@end
