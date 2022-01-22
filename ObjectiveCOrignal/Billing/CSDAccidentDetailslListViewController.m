//
//  CSDAccidentDetailslListViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/12/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "CSDAccidentDetailslListViewController.h"
#import "DataRepository.h"
#import "NSDate+Misc.h"
#import "NSDate+Helpers.h"

#import "AccidentVehicleReport+CoreDataClass.h"
#import "AccidentVehicle+CoreDataClass.h"
#import "CSDVehicleAccidentViewController.h"
#import "AccidentTrailerDollie+CoreDataClass.h"
#import "AccidentWitness+CoreDataClass.h"

#define KeyDetail @"detail"

@interface CSDAccidentDetailslListViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemsFiltered;

@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@end

@implementation CSDAccidentDetailslListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.accident.name;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commandLoaded" object:nil];
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveButtonPressed:)];

    [self loadItems];
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    [self setScreenTitle];
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

-(void)setScreenTitle {
    switch (self.recordType) {
        case AccidentRecordTypeVehicle:
            self.title = @"Vehicles";
            break;
        case AccidentRecordTypeWitness:
            self.title = @"Witnesses";
            break;
        case AccidentRecordTypeTrailerDollie:
            self.title = @"Trailer&Dollies";
            break;
        default:
            self.title = nil;
            break;
    }
}

-(void)loadItems {
    NSPredicate *predicate = nil;
    
    if (self.accident.rcoBarcode.length) {
        predicate = [NSPredicate predicateWithFormat:@"rcoBarcodeParent = %@", self.accident.rcoBarcode];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"rcoObjectParentId = %@", self.accident.rcoObjectId];
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
    [self showForm:nil];
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
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"CSDAccidentDetailCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CSDAccidentDetailCell"];
    }
    
    id record = [self.items objectAtIndex:indexPath.row];
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    [cell.textLabel setNumberOfLines:2];
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", (int)(indexPath.row +1), [self getAccidentRecordDescription:record]];
    cell.detailTextLabel.text = [self getAccidentRecordDescriptionDetail:record];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

-(NSString*)getAccidentRecordDescription:(id)record {
    NSString *desc = nil;
    switch (self.recordType) {
        case AccidentRecordTypeVehicle: {
            AccidentVehicle *vehicle = (AccidentVehicle*)record;
            desc = [NSString stringWithFormat:@"License Plate Number: %@", vehicle.number];
        }
            break;
        case AccidentRecordTypeWitness: {
            AccidentWitness *witness = (AccidentWitness*)record;
            desc = [NSString stringWithFormat:@"%@ %@", witness.firstName, witness.lastName];
        }
            break;
        case AccidentRecordTypeTrailerDollie: {
            AccidentTrailerDollie *td = (AccidentTrailerDollie*)record;
            desc = [NSString stringWithFormat:@"License Plate Number: %@", td.licensePlateNumber];
        }
            break;
            default:
            break;
    }
    return desc;
}

-(NSString*)getAccidentRecordDescriptionDetail:(id)record {
    NSString *desc = nil;
    switch (self.recordType) {
        case AccidentRecordTypeVehicle: {
            AccidentVehicle *vehicle = (AccidentVehicle*)record;
            desc = [NSString stringWithFormat:@"%@ %@", vehicle.firstName, vehicle.lastName];
        }
            break;
        case AccidentRecordTypeWitness: {
        }
            break;
        case AccidentRecordTypeTrailerDollie: {
            AccidentTrailerDollie *td = (AccidentTrailerDollie*)record;
            desc = [NSString stringWithFormat:@"Dolly Type: %@", td.dollyType];
        }
            break;
        default:
            break;
    }
    return desc;
}


-(void)showForm:(id)detail {
    
    CSDVehicleAccidentViewController *controller = [[CSDVehicleAccidentViewController alloc] initWithNibName:@"CSDVehicleAccidentViewController" bundle:nil];
    controller.accidentRecord = detail;
    controller.accident = self.accident;
    controller.addDelegate = self;
    controller.addDelegateKey = KeyDetail;
    controller.recordType = self.recordType;
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id detail = [self.itemsFiltered objectAtIndex:indexPath.row];
    [self showForm:detail];
}

-(void)deleteSelectedItem {

}

-(Aggregate*)aggregate {
    switch (self.recordType) {
        case AccidentRecordTypeVehicle:
            return [[DataRepository sharedInstance] getAggregateForClass:@"AccidentVehicle"];
            break;
        case AccidentRecordTypeWitness:
            return [[DataRepository sharedInstance] getAggregateForClass:@"AccidentWitness"];
            break;
        case AccidentRecordTypeTrailerDollie:
            return [[DataRepository sharedInstance] getAggregateForClass:@"AccidentTrailerDollie"];
            break;
        default:
            break;
    }
    return nil;
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
