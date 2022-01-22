//
//  FilterWithOptionsViewController.m
//  MobileOffice
//
//  Created by Dragos Dragos on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "FilterWithOptionsViewController.h"
#import "InputCell.h"
#import "DateSelectorViewController.h"
#import "DataRepository.h"
#import "RCOObjectListViewController.h"
#import "RCOValuesListViewController.h"
#import "FieldLog.h"
#import "FieldLogAggregate.h"
#import "Location+CoreDataProperties.h"
#import "LocationsAggregate.h"
#import "FarmTask.h"
#import "Field.h"
#import "FarmOperation+CoreDataClass.h"
#import "FarmOperationAggregate.h"
#import "NSDate+Misc.h"
#import "LaborGroup.h"
#import "ProductCategory+CoreDataProperties.h"
#import "ProductType+CoreDataProperties.h"

@interface FilterWithOptionsViewController ()
@property (nonatomic, strong) NSArray *dateOptions;

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) NSMutableArray *valuesSelected;

@end

@implementation FilterWithOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveTapped:)];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.values = [NSMutableDictionary dictionary];

    [self loadObject];

    self.title = @"Filter";
    
    self.dateOptions = [NSArray arrayWithObjects:DateString_Today, DateString_Yesterday, DateString_ThisWeek, DateString_LastWeek, DateString_ThisMonth, DateString_LastMonth, DateString_ThisYear, DateString_LastYear, @"All", nil];

    self.navigationItem.rightBarButtonItem = nil;
    
    if (self.enableSave) {
        //09.01.2020 we should enable save if we are passing a value
        self.navigationItem.rightBarButtonItem = self.saveBtn;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)loadObject {
    self.valuesSelected = [NSMutableArray array];
    for (id obj in self.optionsSelected) {
        [self.valuesSelected addObject:obj];
    }
}

#pragma mark Actions

-(IBAction)cancelButtonPressed:(id)sender {
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(IBAction)saveTapped:(id)sender {
    // send the values back
    NSMutableArray *objs = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    
    if (self.customDate) {
        [objs addObject:self.customDate];
        [keys addObject:KEY_DateCustom];
    } else if (self.selectedDate) {
        [objs addObject:self.selectedDate];
        [keys addObject:KEY_Date];
    }

    for (NSInteger i = 0; i < self.options.count; i++) {
        NSString *key = [self.options objectAtIndex:i];
        id obj = [self.valuesSelected objectAtIndex:i];
        [objs addObject:obj];
        [keys addObject:key];
    }

    if ([self.addDelegate respondsToSelector:@selector(didAddObjects:forKeys:)]) {
        [self.addDelegate didAddObjects:objs forKeys:keys];
    }
}


#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.dateOptions.count;
    } else if (section == 2) {
        return 1;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 + self.options.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Custom Date";
    } else if (section == 1) {
        return @"Date";
    } else {
        NSInteger index = section - 2;
        if (index < self.options.count) {
            NSString *key = [self.options objectAtIndex:index];
            return key;
        } else {
            return @" ";
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *value = nil;
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"groupFilter"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupFilter"];
    }
    
    UIImage *img = nil;
    
    if (indexPath.section == 0) {
        // custom date
        if (self.customDate) {
            value = [self.customDate rcoDateRMSToString:self.customDate];
        } else {
            value = @"Not Set!";
        }
        img = [UIImage imageNamed:@"CALENDAR"];
    } else if (indexPath.section == 1) {
        // date
        value = [self.dateOptions objectAtIndex:indexPath.row];
    } else {
        NSInteger index = indexPath.section - 2;
        
        if (index < self.options.count) {
            RCOObject *obj = [self.valuesSelected objectAtIndex:index];
            
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *val = (NSString*)obj;
                if (val.length) {
                    value = val;
                } else {
                    value = @"Not Set";
                }
            } else if ([obj isKindOfClass:[RCOObject class]]){
                value = [self getObjectDescription:obj];
            }

            img = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            value = Key_Remove_Filter;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    cell.textLabel.text = value;
    cell.imageView.image = img;
    
    if ((indexPath.section == 0) || (indexPath.section == 1)) {
        if ([self.selectedDate isEqualToString:value] && !(self.customDate)) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        [self showDatePickerFromView:cell andKey:KEY_DateCustom];
    } else if (indexPath.section == 1) {
        self.selectedDate = [self.dateOptions objectAtIndex:indexPath.row];
        self.customDate = nil;
        self.navigationItem.rightBarButtonItem = self.saveBtn;
    } else {
        NSInteger index = indexPath.section - 2;
        if (index < self.options.count) {
            // show ickers for different keys
            NSString *key = [self.options objectAtIndex:index];
            [self showRecordPickerForKey:key fromView:cell];
        } else {
            self.selectedDate = nil;
            for (NSInteger i = 0; i < self.valuesSelected.count; i++) {
                [self.valuesSelected replaceObjectAtIndex:i withObject:@""];
            }
            self.customDate = nil;
            
        }
        self.navigationItem.rightBarButtonItem = self.saveBtn;
    }
    
    [self.tableView reloadData];
}

-(NSString*)getObjectDescription:(RCOObject*)obj {
    if ([obj isKindOfClass:[ProductType class]]) {
        ProductType *pt = (ProductType*)obj;
        return pt.name;
    } else if ([obj isKindOfClass:[ProductCategory class]]) {
        ProductCategory *pc = (ProductCategory*)obj;
        return pc.name;
    } else if ([obj isKindOfClass:[User class]]) {
        User *user = (User*)obj;
        
        if ([user.userType isEqualToString:kUserTypeVendorGrower]) {
            return [NSString stringWithFormat:@"%@", user.company];
        }
    }
    return @"Not Set";
}

-(void)showRecordPickerForKey:(NSString*)key fromView:(UIView*)fromView {
    
    if ([key isEqualToString:[User objectGrowerFilterKey]]) {
        // show grower picker
        [self showGrowerPickerFromView:fromView];
    } else if ([key isEqualToString:[ProductType objectFilterKey]]) {
        // show product type picker
        [self showProductTypePickerFromView:fromView];
    } else if ([key isEqualToString:[ProductCategory objectFilterKey]]) {
        // show category picker
        [self showProductCategoryPickerFromView:fromView];
    }
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

- (void)showGrowerPickerFromView:(UIView*)fromView {
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [DataRepository sharedInstance].vendorAggregate;
    
    fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
    sortKey = @"surname";
    
    // for growers we should display company
    fields = [NSArray arrayWithObjects:@"company", nil];
    sortKey = @"company";
    title = @"Growers";
    
    predicate = [NSPredicate predicateWithFormat:@"userType = %@", UserTypeGrower];
    //predicate = [NSPredicate predicateWithFormat:@"userType = %@ and isActive = %@", UserTypeGrower, [NSNumber numberWithBool:YES]];
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:[User objectGrowerFilterKey]
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = [User objectGrowerFilterKey];
    listController.showIndexNumber = YES;
    listController.title = title;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showProductTypePickerFromView:(UIView*)fromView {
    
    NSString *productCategoryKey = [ProductCategory objectFilterKey];
    
    NSInteger index = [self.options indexOfObject:productCategoryKey];
    
    if (index == NSNotFound) {
        [self showSimpleMessage:@"Product Category key not added!"];
        return;
    }
    
    ProductCategory *prodCategory = [self.valuesSelected objectAtIndex:index];
    if (![prodCategory isKindOfClass:[ProductCategory class]]) {
        [self showSimpleMessage:@"Please set Product Category first!"];
        return;

    }
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"ProductType"];
    
    fields = [NSArray arrayWithObjects:@"name", nil];
    sortKey = @"name";
    title = NSLocalizedString(@"Product Type", nil);
    predicate = [NSPredicate predicateWithFormat:@"category=%@", prodCategory.name];
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:[ProductType objectFilterKey]
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = [ProductType objectFilterKey];
    listController.title = title;
    
    index = [self.options indexOfObject:[ProductType objectFilterKey]];
    if (index != NSNotFound) {
        ProductType *productType = [self.valuesSelected objectAtIndex:index];
        if ([productType isKindOfClass:[ProductType class]]) {
            listController.selectedItem = productType;
        }
    }
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showProductCategoryPickerFromView:(UIView*)fromView {
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"ProductCategory"];
    
    fields = [NSArray arrayWithObjects:@"name", nil];
    sortKey = @"name";
    title = NSLocalizedString(@"Product Category", nil);
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:[ProductCategory objectFilterKey]
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = [ProductCategory objectFilterKey];
    listController.title = title;
    
    NSInteger index = [self.options indexOfObject:[ProductCategory objectFilterKey]];
    if (index != NSNotFound) {
        ProductCategory *productCategory = [self.valuesSelected objectAtIndex:index];
        if ([productCategory isKindOfClass:[ProductCategory class]]) {
            listController.selectedItem = productCategory;
        }
    }

    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

- (void)showGroupPickerFromView:(UIView*)fromView {
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:@"LaborGroup"];
    
    fields = [NSArray arrayWithObjects:@"name", nil];
    
    sortKey = @"name";
    
    title = @"Groups";
    
    predicate = nil;
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:KEY_Group
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = KEY_Group;
    listController.title = title;
  /*
    if (self.laborGroup) {
        listController.selectedItem = self.laborGroup;
    }
*/
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromView:fromView];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}



-(void)showDatePickerFromView:(UIView*)fromView andKey:(NSString*)key  {
    DateSelectorViewController *controller = [[DateSelectorViewController alloc] initWithNibName:@"DateSelectorViewController"
                                                                                          bundle:nil
                                                                                        forDates:[NSArray arrayWithObject:key]];
    controller.selectDelegate = self;
    controller.shouldPopUpOnIpad = YES;
    controller.isSimpleDatePicker = YES;
    
    NSDate *date = nil;
    
    if ([key isEqualToString:KEY_DateCustom]) {
        controller.title = @"Date";
        date = self.customDate;
    }
    
    if (!date) {
        date = [NSDate date];
    }
    
    controller.currentDate = date;
    
    if (DEVICE_IS_IPHONE) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self showPopoverForViewController:controller fromView:fromView];
    }
}

#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
    if ([key isEqualToString:KEY_DateCustom]) {
        NSLog(@"");
        if ([object isKindOfClass:[NSDate class]]) {
            self.customDate = (NSDate*)object;
            self.navigationItem.rightBarButtonItem = self.saveBtn;
        }
    } else if ([key isEqualToString:[User objectGrowerFilterKey]]) {
        
        NSInteger index = [self.options indexOfObject:key];
        
        if (index != NSNotFound) {
            if ([object isKindOfClass:[User class]]) {
                [self.valuesSelected replaceObjectAtIndex:index withObject:object];
            }
        }
        if (DEVICE_IS_IPHONE) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }  else if ([key isEqualToString:[ProductType objectFilterKey]]) {
        
        NSInteger index = [self.options indexOfObject:key];
        
        if (index != NSNotFound) {
            if ([object isKindOfClass:[ProductType class]]) {
                [self.valuesSelected replaceObjectAtIndex:index withObject:object];
            }
        }
        if (DEVICE_IS_IPHONE) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }   else if ([key isEqualToString:[ProductCategory objectFilterKey]]) {
        
        NSInteger index = [self.options indexOfObject:key];
        
        if (index != NSNotFound) {
            if ([object isKindOfClass:[ProductCategory class]]) {
                [self.valuesSelected replaceObjectAtIndex:index withObject:object];
            }
        }
        if (DEVICE_IS_IPHONE) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    ////[self.popoverCtrl dismissPopoverAnimated:YES];
    [self.tableView reloadData];
}

-(Aggregate*)aggregate {
    return nil;
}

-(void)requestSucceededForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
}

-(void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate:(Aggregate*)aggregate {
    
}

@end
