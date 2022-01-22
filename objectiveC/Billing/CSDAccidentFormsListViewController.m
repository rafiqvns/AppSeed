//
//  CSDAccidentFormsListViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/12/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDAccidentFormsListViewController.h"
#import "DataRepository.h"
#import "NSDate+Misc.h"
#import "NSDate+Helpers.h"

#import "AccidentVehicleReport+CoreDataClass.h"
#import "CSDAccidentVehicleReportViewController.h"
#import "UserAggregate.h"
#import "RCOObjectListViewController.h"

#define KeyTest @"Test"

@interface CSDAccidentFormsListViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemsTemplates;
@property (nonatomic, strong) NSMutableArray *itemsFiltered;
@property (nonatomic, strong) NSMutableArray *itemsToDelete;
@property (nonatomic, strong) NSMutableDictionary *values;

@property (nonatomic, strong) NSMutableArray *itemsDates;
@property (nonatomic, strong) NSMutableDictionary *itemsInfo;

@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;

@property (nonatomic, strong) UIBarButtonItem *editBtn;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;
@property (nonatomic, strong) UIAlertController *al;

@property (nonatomic, assign) BOOL isTemplate;
@property (nonatomic, assign) BOOL useSameFlow;
@property (nonatomic, strong) RCOObject *templateForm;
@property (nonatomic, strong) NSIndexPath *selectedRow;

@property (nonatomic, assign) BOOL sendAlerts;

@end

@implementation CSDAccidentFormsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Accidents";
    
    self.useSameFlow = YES;
    
    // 25.06.2019 turn on/off alerts via email
    self.sendAlerts = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commandLoaded" object:nil];

    self.editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                 target:self
                                                                 action:@selector(editButtonPressed:)];
    
    self.doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                 target:self
                                                                 action:@selector(doneButtonPressed:)];

    self.navigationItem.rightBarButtonItem = self.editBtn;
    
    [self loadItems];
    
    [self addButtonPressed:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self aggregate] registerForCallback:self];
    [self.tableView reloadData];
    if (self.selectedRow) {
        [self.tableView selectRowAtIndexPath:self.selectedRow animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self aggregate] unRegisterForCallback:self];
}

-(void)loadItems {
    NSPredicate *predicate = nil;
    NSArray *res = nil;
    NSString *employeeId = [[DataRepository sharedInstance] getLoggedUserEmployeeId];

    if (employeeId.length) {
        predicate = [NSPredicate predicateWithFormat:@"employeeId=%@", employeeId];
    }
    
    res = [[self aggregate] getAllNarrowedBy:predicate andSortedBy:nil];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"dateTime" ascending:NO];
    res = [res sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    self.items = [NSMutableArray arrayWithArray:res];
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    [self formatList];
}

-(void)formatList {
    self.itemsInfo = [NSMutableDictionary dictionary];
    self.itemsDates = [NSMutableArray array];
    
    for (RCOObject *form in self.itemsFiltered) {
        NSDate *date = [form.dateTime dateWithoutTime];
        if (![self.itemsDates containsObject:date]) {
            [self.itemsDates addObject:date];
        }
        
        NSMutableArray *arr = [self.itemsInfo objectForKey:date];
        if (!arr) {
            arr = [NSMutableArray array];
        }
        [arr addObject:form];
        
        [self.itemsInfo setObject:arr forKey:date];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [self.itemsDates sortUsingDescriptors:[NSArray arrayWithObject:sd]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)editButtonPressed:(id)sender {
    self.itemsToDelete = [NSMutableArray array];
    self.navigationItem.rightBarButtonItem = self.doneBtn;
    [self.tableView setEditing:YES];
}

-(IBAction)doneButtonPressed:(id)sender {
    
    for (RCOObject *obj in self.itemsToDelete) {
        [[self aggregate] destroyObj:obj];
    }
    
    self.navigationItem.rightBarButtonItem = self.editBtn;
    [self.tableView setEditing:NO];
}

-(void)showForm:(AccidentVehicleReport*)header {
    if (DEVICE_IS_IPHONE || self.useSameFlow) {
        CSDAccidentVehicleReportViewController *controller = [[CSDAccidentVehicleReportViewController alloc] initWithNibName:@"CSDAccidentVehicleReportViewController" bundle:nil];
        controller.header = header;
        controller.addDelegate = self;
        controller.addDelegateKey = KeyTest;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        if ([self.selectionDelegate respondsToSelector:@selector(RCOSpliterSelectedObject:)]) {
            [self.selectionDelegate RCOSpliterSelectedObject:nil];
        }
    }
}

-(IBAction)addButtonPressed:(UIBarButtonItem*)sender {
    /*
    NSString *msg = [self checkOpenTests];
    if (msg) {
        [self showSimpleMessage:msg];
        return;
    }
    self.selectedRow = nil;
    */
    /*
     27.06.2019 moved in the accident screen
    [self sendAlert:nil];
     */
    [self showForm:nil];
}

-(void)sendAlert:(NSString*)binNumber {
    /*
     27.06.2019 moved in the accident screen
    if (!self.sendAlerts) {
        return;
    }
    
    AlertGroupAggregate *agg = (AlertGroupAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"AlertGroup"];
    AlertGroup *alert = (AlertGroup*)[agg createNewObject];
    
    User *user = [[DataRepository sharedInstance] getUserLoggedIn];
    
    NSString *subject = [NSString stringWithFormat:@"Accident Form STARTED by:%@", [user Name]];
    NSString *message = [NSString stringWithFormat:@"Student ID:  %@", [user employeeNumber]];
    alert.message = message;
    alert.functionalGroupName = AlertsCSDAccident;
    alert.subject = subject;
    alert.itemType = ItemTypeAlertEmailNoAttachment;
    [alert setNeedsUploading:YES];
    [agg createNewRecord:alert];
    */
}

-(NSString*)checkOpenTests {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endTime.length=0"];
    NSArray *res = [self.itemsFiltered filteredArrayUsingPredicate:predicate];
    if (res.count > 1) {
        return [NSString stringWithFormat:@"Please close %d tests first!", (int)res.count];
    } else if (res.count == 1) {
        return @"Please close opened test first!";
    }
    return nil;
}

-(IBAction)actionButtonPressed:(id)sender {
    return;
}

#pragma mark UITableViewDataSource
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Delete item?";
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDate *date = [self.itemsDates objectAtIndex:indexPath.section];
        NSMutableArray *arr = [self.itemsInfo objectForKey:date];

        id obj = [arr objectAtIndex:indexPath.row];
        
        [arr removeObjectAtIndex:indexPath.row];
        
        [self.itemsToDelete addObject:obj];
        
        if (arr.count == 0) {
            [self.itemsInfo removeObjectForKey:date];
            [self.itemsDates removeObject:date];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.itemsInfo setObject:arr forKey:date];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        NSLog(@"");
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isTemplate) {
        return self.itemsTemplates.count;
    } else {
        NSDate *date = [self.itemsDates objectAtIndex:section];
        NSArray *arr = [self.itemsInfo objectForKey:date];
        return [arr count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isTemplate) {
        return 1;
    } else {
        return [self.itemsDates count];
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isTemplate) {
        return [NSString stringWithFormat:@"Templates(%d)", (int)self.itemsTemplates.count];
    }
    NSDate *date = [self.itemsDates objectAtIndex:section];

    return [NSString stringWithFormat:@"%@", [self.aggregate rcoDateToString:date]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    /*
    TestDataHeader *form = nil;
    NSDate *date = [self.itemsDates objectAtIndex:indexPath.section];
    NSArray *items = [self.itemsInfo objectForKey:date];
        
    form = [items objectAtIndex:indexPath.row];

    if (DEVICE_IS_IPHONE || self.useSameFlow) {
        CSDTestViewController *controller = [[CSDTestViewController alloc] initWithNibName:@"CSDTestViewController" bundle:nil];
        controller.header = form;
        controller.addDelegate = self;
        controller.addDelegateKey = KeyTest;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        if ([self.selectionDelegate respondsToSelector:@selector(RCOSpliterSelectedObject:)]) {
            [self.selectionDelegate RCOSpliterSelectedObject:form];
        }
    }
    */
}

-(UITableViewCell*)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"QCFormHeaderCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"QCFormHeaderCell"];
    }
    
    NSDate *date = nil;
    NSArray *arr = nil;
    
    date = [self.itemsDates objectAtIndex:indexPath.section];
    arr = [self.itemsInfo objectForKey:date];
    
    AccidentVehicleReport *form = nil;
    form = [arr objectAtIndex:indexPath.row];
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:17]];
    [cell.textLabel setNumberOfLines:2];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@ %@", (int)(indexPath.row + 1), [form lastName], [form firstName]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [form location]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
}

-(void)showFormInfo:(RCOObject*)form {
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AccidentVehicleReport *form = nil;
    NSDate *date = [self.itemsDates objectAtIndex:indexPath.section];
    NSArray *items = [self.itemsInfo objectForKey:date];
        
    form = [items objectAtIndex:indexPath.row];
    [self showForm:form];
    self.selectedRow = indexPath;
    [self showFormInfo:form];
}

-(void)deleteSelectedItem {

}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"AccidentVehicleReport"];
}

- (void)objectSyncComplete: (Aggregate *) fromAggregate {
    [self.tableView reloadData];
}

#pragma mark AddObject Methods

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([key isEqualToString:KeyTest]) {
        // 01.02.2019 we should check here if we tapped on the cancel button or if we saved the Test
        if (/*object*/1) {
            [self loadItems];
            if ([object isKindOfClass:[AccidentVehicleReport class]]) {
                // we should select this form
                NSLog(@"");
                self.selectedRow = [self getIndexPathForItem:(AccidentVehicleReport *)object];
            }
        }
    }
    
    if (DEVICE_IS_IPHONE || self.useSameFlow) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    [self.tableView reloadData];
    if (self.selectedRow) {
        [self.tableView selectRowAtIndexPath:self.selectedRow animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

-(NSIndexPath*)getIndexPathForItem:(AccidentVehicleReport*)item {
    NSDate *date = [item.dateTime dateWithoutTime];
    NSInteger section = [self.itemsDates indexOfObject:date];
    NSInteger row = NSNotFound;
    
    if (section != NSNotFound) {
        NSArray *arr = [self.itemsInfo objectForKey:date];
        row = [arr indexOfObject:item];
    }
    if (section != NSNotFound && row != NSNotFound) {
        return [NSIndexPath indexPathForRow:row inSection:section];
    }
    return nil;
}

-(void)didAddObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    [self.tableView reloadData];
}

#pragma mark ----

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    [self.progressHUD hide:YES];
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    [self.progressHUD hide:YES];
}

#pragma mark UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rcoObjectSearchString contains[cd] %@", searchText];
        self.itemsFiltered = [NSMutableArray arrayWithArray:[self.items filteredArrayUsingPredicate:predicate]];
        self.filterPredicate = predicate;
    } else {
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
        self.filterPredicate = nil;
    }

    [self formatList];
    [self.tableView reloadData];
}

@end
