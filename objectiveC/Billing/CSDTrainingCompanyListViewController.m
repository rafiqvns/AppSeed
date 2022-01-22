//
//  CSDTrainingCompanyListViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/12/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDTrainingCompanyListViewController.h"
#import "DataRepository.h"
#import "NSDate+Misc.h"
#import "NSDate+Helpers.h"
#import "TrainingCompany+CoreDataClass.h"
#import "Settings.h"

@interface CSDTrainingCompanyListViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemsFiltered;
@property (nonatomic, strong) NSMutableDictionary *itemsIndexed;
@property (nonatomic, strong) NSMutableArray *indexes;

@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@end

@implementation CSDTrainingCompanyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Companies";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commandLoaded" object:nil];
    [self loadItems];
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
    
    NSPredicate *finalPredicate = nil;
    NSArray *res = nil;
    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *userCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    if (![[userCompany lowercaseString] containsString:[organizationName lowercaseString]]) {
        finalPredicate = [NSPredicate predicateWithFormat:@"name=%@", userCompany];
    }
    
    res = [[self aggregate] getAllNarrowedBy:finalPredicate andSortedBy:nil];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.items = [NSMutableArray arrayWithArray:[res sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    
    [self groupItems];
    
    [self.tableView reloadData];
}

-(void)groupItems {
    self.itemsIndexed = [NSMutableDictionary dictionary];
    self.indexes = [NSMutableArray array];
    
    for (RCOObject *obj in self.itemsFiltered) {
        NSString *lastName = [obj valueForKey:@"name"];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)reloadButtonPressed:(id)sender {
    self.items = [NSMutableArray array];
    self.itemsFiltered = [NSMutableArray array];
    self.search.text = nil;
    [self.view endEditing:YES];
    [self.tableView reloadData];
}

-(IBAction)actionButtonPressed:(id)sender {
    return;
}

#pragma mark UITableViewDataSource

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

-(UITableViewCell*)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"CompanyCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CompanyCell"];
    }
    
    NSString *key = [self.indexes objectAtIndex:indexPath.section];
    NSArray *arr = [self.itemsIndexed objectForKey:key];
    TrainingCompany *obj = [arr objectAtIndex:indexPath.row];
    
    NSString *info = [obj name];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", info, obj.number];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@", obj.address, obj.city, obj.state];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexes;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.indexes objectAtIndex:index];
}


-(NSString*)getAlarmDescription:(NSDictionary*)recordInfo {
    NSString *desc = [recordInfo objectForKey:@"Name"];
    return desc;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(void)deleteSelectedItem {

}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
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

#pragma mark ----

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];

}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    [self.progressHUD hide:YES];
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rcoObjectSearchString contains[cd] %@", searchText];
        NSArray *arr = [self.items filteredArrayUsingPredicate:predicate];
        self.itemsFiltered = [NSMutableArray arrayWithArray:arr];
        self.filterPredicate = predicate;
    } else {
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
        self.filterPredicate = nil;
    }
    
    [self groupItems];
    
    [self.tableView reloadData];
}

@end
