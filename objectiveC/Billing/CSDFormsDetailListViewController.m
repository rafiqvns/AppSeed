//
//  CSDFormsDetailListViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/12/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDFormsDetailListViewController.h"
#import "DataRepository.h"
#import "NSDate+Misc.h"
#import "NSDate+Helpers.h"

#import "TestDataHeader+CoreDataClass.h"
#import "TestDataDetail+CoreDataClass.h"

#define KeyDetail @"detail"

@interface CSDFormsDetailListViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemsFiltered;

@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@end

@implementation CSDFormsDetailListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.header.name;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commandLoaded" object:nil];
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveButtonPressed:)];

    [self loadItems];
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    //if (self.headerQC.verifiedDateTime) {
        [self.verifyBtn setEnabled:NO];
    //}
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

-(void)loadItems {
    NSPredicate *predicate = nil;
    
    if (self.header.rcoBarcode.length) {
        predicate = [NSPredicate predicateWithFormat:@"rcoBarcodeParent = %@", self.header.rcoBarcode];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"rcoObjectParentId = %@", self.header.rcoObjectId];
    }
    
    NSArray *res = [[self aggregate] getAllNarrowedBy:predicate andSortedBy:nil];
    
    self.items = [NSMutableArray arrayWithArray:res];
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(IBAction)addButtonPressed:(id)sender {
}

-(IBAction)verifyButtonPressed:(id)sender {
    NSString *msg = @"Form Verified?";
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:msg
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self markVerified];
                                                          [self.verifyBtn setEnabled:NO];
                                                      }];
    
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                     }];
    
    [al addAction:yesAction];
    [al addAction:noAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(void)markVerified {
    /*
    UserAggregate *agg = [[DataRepository sharedInstance] getUserAggregateAvailablePlus];
    NSString *currentUserRecordId = [[DataRepository sharedInstance] getLoggedUserRecordId];
    User *usr = [agg getAnyUserWithRecordId:currentUserRecordId];
    self.headerQC.verifiedByName = [usr Name];
    self.headerQC.verifiedDateTime = [NSDate date];
    self.headerQC.verifiedByRecordId = usr.rcoRecordId;
    self.headerQC.verifiedByEmployeeId = usr.employeeNumber;
    
    Aggregate *headerAgg =  [[DataRepository sharedInstance] getAggregateForClass:@"QCFormHeader"];
    [headerAgg createNewRecord:self.headerQC];
    [self.tableView reloadData];
    */
}

-(IBAction)actionButtonPressed:(id)sender {
    return;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
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
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"QCFormDetailCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"QCFormDetailCell"];
    }
    
    TestDataDetail *detail = [self.items objectAtIndex:indexPath.row];
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    [cell.textLabel setNumberOfLines:2];
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", detail.number, detail.name];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}


-(void)deleteSelectedItem {

}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"TestDataDetail"];
}

- (void)objectSyncComplete: (Aggregate *) fromAggregate {
    [self.tableView reloadData];
}

#pragma mark AddObject Methods

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([key isEqualToString:KeyDetail]) {
        if (object) {
            [self loadItems];
        }
    }
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

#pragma mark ----

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    [self.progressHUD hide:YES];
}

#pragma mark UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableView reloadData];
}

@end
