//
//  RCOObjectListViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 7/11/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "RCOObjectListViewController.h"
#import "Aggregate.h"
#import "DataRepository.h"
#import "BillingAppDelegate.h"
#import "Settings.h"
#import "NSManagedObjectContext+Timing.h"
#import "UIViewController+iOS6.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+TKCategory.h"
#import "User_Imp.h"
#import "NSDate+TKCategory.h"


@interface RCOObjectListViewController ()
@property (nonatomic, strong) NSMutableArray *itemsFiltered;

@property (nonatomic, strong) NSArray *secondItems;
@property (nonatomic, strong) NSMutableArray *secondItemsFiltered;
@property (nonatomic, strong) NSArray *secondItemsFields;

@property (nonatomic, strong) NSArray *itemsAssemblies;
@property (nonatomic, strong) NSMutableArray *itemsAssembliesFiltered;
@property (nonatomic, strong) NSMutableArray *colors;

@end

@implementation RCOObjectListViewController

@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil aggregate:(Aggregate*)objectAggregate fields:(NSArray*)objectFields detailFields:(NSArray*)detailFields forKey:(NSString*)key filterByPredicate:(NSPredicate*)predicate andSortedBy:(NSString*)sortKey {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _aggregate = objectAggregate;
        _fields = objectFields;
        _key = key;
        _predicate = predicate;
        _sortKey = sortKey;
        _detailFields = detailFields;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil aggregate:(Aggregate*)objectAggregate fields:(NSArray*)objectFields forKey:(NSString*)key filterByPredicate:(NSPredicate*)predicate andSortedBy:(NSString*)sortKey
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil aggregate:objectAggregate fields:objectFields detailFields:nil forKey:key filterByPredicate:predicate andSortedBy:sortKey];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil aggregate:(Aggregate*)objectAggregate fields:(NSArray*)objectFields detailFields:(NSArray*)detailFields forKey:(NSString*)key filterByPredicate:(NSPredicate*)predicate andSortedBy:(NSString*)sortKey editable:(BOOL)editable {
    
    id res = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil aggregate:objectAggregate fields:objectFields detailFields:detailFields forKey:key filterByPredicate:predicate andSortedBy:sortKey];
    
    if (res) {
        _editable = editable;
    }
    
    return res;
}

-(BOOL)allowMultipleSelection {
    return self.showAllUsers && self.selectedItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mainItems = YES;
    if (!_editable && !self.enableDeleteItem && !self.enableAddUserItem && self.editToolbar) {
        [self.editToolbar removeFromSuperview];
        CGRect tableFame = self.tableView.frame;
        tableFame.size.height += self.editToolbar.frame.size.height;
        [self.tableView setFrame:tableFame];
    }

    if ([self.items count] == 0) {
        if (self.showAllUsers) {
        } else {
            [self loadList];
        }
    } else {
        // we have the items loaded
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    }
    
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    if (self.resetPreviousSelection) {
        cancelButtonTitle = NSLocalizedString(@"Clear", nil);
    }
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:cancelButtonTitle
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if (self.showClearButton) {
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil)
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(clearPressed:)];
        self.navigationItem.rightBarButtonItem = clearButton;
    }
    if ([self allowMultipleSelection]) {
        if (!self.isViewMode) {
            // we need a save button
            UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                        target:self
                                                                                        action:@selector(savePressed:)];
            self.navigationItem.rightBarButtonItem = saveButton;
        }
    }
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarColor]];
    [[UIToolbar appearance] setBarTintColor:[UIColor toolBarColor]];
    
    if (self.showEmptyList) {
        CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44);
        UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
        lbl.text = @"   *Users will show after start searching...";
        lbl.font = [UIFont systemFontOfSize:11];
        self.tableView.tableHeaderView = lbl;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateTableViewFrame:toInterfaceOrientation];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL changeFrame = NO;
    
    if (IS_OS_8_OR_LATER) {
        changeFrame = YES;
    }
    
    if (self.isViewControllerPushed || changeFrame) {
        [self updateTableViewFrame:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    [self.tableView reloadData];
}

-(void)updateTableViewFrame:(UIInterfaceOrientation)orientation {
    
    if ([self.navigationController.viewControllers count] == 0) {
        // this is the case when is showed in settings
        return;
    }
    
    CGFloat y = [self getStartingCoordinateY:orientation];
        
    CGRect frame = self.searchBar.frame;
    frame.origin.y = self.view.frame.origin.y + y;
    
    self.searchBar.frame = frame;
    
    frame = self.view.frame;
    frame.origin.y = self.searchBar.frame.origin.y + 44;
    frame.size.height = self.view.frame.size.height - 44 - y;
    if (_editable || self.enableDeleteItem || self.enableAddUserItem) {
        frame.size.height -= 44;
    }
    
    self.tableView.frame = frame;
}

-(void)loadItems {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPersistentStoreCoordinator *coordinator = [[DataRepository sharedInstance] persistentStoreCoordinator];
    
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    
    if (coordinator != nil) {
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

        [context performBlockAndWait:^{
            NSManagedObjectContext *parentContext = [DataRepository sharedInstance].masterSaveContext;
            [context setParentContext:parentContext];
            [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        }];

        if (![NSThread isMainThread]) {
            /*
             21.03.2016, we should not set if is the main thread, it can invalidate the context
             */
            [threadDict setObject:context forKey:kMobileOfficeKey_MOC];
        }

        __block NSArray *fetchedObjects = nil;
        
        [context performBlockAndWait:^{
            // Edit the entity name as appropriate.
            NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            
            [fetchRequest setIncludesSubentities:NO];
            [fetchRequest setResultType:NSDictionaryResultType];
            
            NSMutableArray *allFields = [NSMutableArray arrayWithArray:_fields];
            [allFields addObjectsFromArray:_detailFields];
            
            [allFields addObject:@"rcoObjectSearchString"];
            
            fetchRequest.propertiesToFetch = [NSArray arrayWithArray:allFields];
            
            NSArray *sortDescriptors = [self sortDescriptors];
            
            if (nil != sortDescriptors) {
                [fetchRequest setSortDescriptors:sortDescriptors];
            }
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                        managedObjectContext:context
                                                                                                          sectionNameKeyPath:[self sectionNameKeyPath]
                                                                                                                   cacheName:nil];
            NSError *error = nil;
            
            NSPredicate *finalPredicate = _predicate;
            
            if (finalPredicate) {
                [aFetchedResultsController.fetchRequest setPredicate:finalPredicate];
            }
            
            NSLog(@"fetch --- start");
            
            [aFetchedResultsController performFetch:&error DATABASE_ACCESS_TIMING_ARGS];
            fetchedObjects = aFetchedResultsController.fetchedObjects;
        }];
        
        NSLog(@"fetch --- end");
        NSLog(@"items = %@", fetchedObjects);

        
        self.items = fetchedObjects;
    }
    
    [self.tableView reloadData];
}

- (NSArray*) sortDescriptors
{
    NSSortDescriptor *partNumberDscriptor = [NSSortDescriptor sortDescriptorWithKey:@"partNumber" ascending:YES];
    
    return [NSArray arrayWithObjects:partNumberDscriptor, nil];
}

- (NSString*) sectionNameKeyPath;
{
    return @"partNumber";
}

- (NSString*) entityName
{
    return @"Part";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    _aggregate = nil;
    _fields = nil;
    
    
    
    
    _predicate = nil;
    _sortKey = nil;
    _key = nil;
    _detailFields = nil;
    
    //self.popoverCtrl = nil;
}

-(void)selectionChanged:(UISegmentedControl*)segControl {
    NSLog(@"selected segment = %d", segControl.selectedSegmentIndex);
    _mainItems = !segControl.selectedSegmentIndex;
    if (_mainItems) {
        self.title = @"";
    } else {
        self.title = @"";
    }
    [self.tableView reloadData];
}

-(void)savePressed:(id)sender {
    if ([self.selectDelegate respondsToSelector:@selector(didAddObjects:forKeys:)]) {
        [self.selectDelegate didAddObjects:self.selectedItems forKeys:[NSArray arrayWithObject:_key]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clearPressed:(id)sender {
    if (DEVICE_IS_IPAD) {
        if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.selectDelegate didAddObject:nil forKey:_key];
        }
        if (self.isViewControllerPushed) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
        } else {
            [self dismissModalViewControllerAnimatediOS6:YES];
        }
    }
}

-(void)cancelPressed:(id)sender {
    if (DEVICE_IS_IPAD) {
        if (self.resetPreviousSelection) {
            if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
                [self.selectDelegate didAddObject:nil forKey:self.addDelegateKey];
            }
        } else {
            if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
                [self.selectDelegate didAddObject:nil forKey:nil];
            }
        }
        if (self.isViewControllerPushed) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if (self.isViewControllerPushed) {
            if (self.resetPreviousSelection) {
                if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
                    [self.selectDelegate didAddObject:nil forKey:self.addDelegateKey];
                }
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [self dismissModalViewControllerAnimatediOS6:YES];
        }
    }
}

-(IBAction)addServiceOrPartButtonPressed:(id)sender {
}



-(IBAction)addButtonPressed:(id)sender {
    
}

-(IBAction)editButtonSwitched:(id)sender {
    UISwitch *switchCtrl = (UISwitch*)sender;
    if (switchCtrl.on) {
        [self.tableView setEditing:YES animated:YES];
    } else {
        [self.tableView setEditing:NO animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if ([self allowMultipleSelection]) {
        return 2;
    }
    
    if (!_mainItems) {
        return 1;
    }
    
    if (self.partsFromAssembliesList) {
        return 2;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self allowMultipleSelection]) {
        if (section == 0) {
            return @"Selected Items";
        } else {
            return NSLocalizedString(@"Items", nil);
        }
    }
    
    if (section == 0) {
        return nil;
    } else {
        return @"Assemblies";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if ([self allowMultipleSelection]) {
        if (section == 0) {
            return  [self.selectedItems count];
        } else {
            return [self.itemsFiltered count];
        }
    }
    if (section == 0) {
        if (_mainItems) {
            return [self.itemsFiltered count];
        } else {
            return [self.secondItemsFiltered count];
        }
    } else {
        return [self.itemsAssembliesFiltered count];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.enableDeleteItem || self.tableView.editing) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (self.enableDeleteItem) {
        
        NSObject *object = [self.itemsFiltered objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:@"Remove: %@", [self getObjDesc:object]];
        
        return message;
    }
    return nil;
}

-(NSString*)getObjDesc:(NSObject*)object {
    NSString *desc = nil;
    
    return desc;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forAssembly:(NSDictionary*)assemblyDict{
    
    NSString *cellIdentifier = @"rcoAssemblyList";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [assemblyDict objectForKey:@"kitName"];
    cell.detailTextLabel.text = [assemblyDict objectForKey:@"kitDescription"];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *fromObjects = nil;
    
    if ([self allowMultipleSelection]) {
        if (indexPath.section == 0) {
            // selected items
            fromObjects = self.selectedItems;
        } else {
            // filtered items
            fromObjects = self.itemsFiltered;
        }

        return [self tableView:tableView
         cellForRowAtIndexPath:indexPath
                   fromObjects:fromObjects];
    } else {
        if (indexPath.section == 0) {
            if (_mainItems) {
                fromObjects = self.itemsFiltered;
            } else {
                fromObjects = self.secondItemsFiltered;
            }
            
            return [self tableView:tableView
             cellForRowAtIndexPath:indexPath
                       fromObjects:fromObjects];
            
        } else {
            fromObjects = self.itemsAssembliesFiltered;
            NSDictionary *dict = [fromObjects objectAtIndex:indexPath.row];
            
            return [self tableView:tableView
             cellForRowAtIndexPath:indexPath
                       forAssembly:dict];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath fromObjects:(NSArray*)objects{

    NSString *cellIdentifier = @"rcoItemList";
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell = nil;
    
    if (cell == nil) {
        if (_detailFields.count > 0 && _mainItems) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    
    NSMutableArray *values = [NSMutableArray array];
    
    NSMutableArray *detailValues = [NSMutableArray array];
    
    if (self.showColorSample) {
    }
    
    RCOObject *object = [objects objectAtIndex:indexPath.row];
    
    NSArray *fieldsToShow = nil;
    
    if (_mainItems) {
        fieldsToShow = _fields;
    } else {
        fieldsToShow = self.secondItemsFields;
    }
    
    for (NSString *key in fieldsToShow) {
        NSObject *obj = nil;
        if ([object isKindOfClass:[RCOObject class]]) {
            obj = [object valueForKey:key];
        } else if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *objDict = (NSDictionary*)object;
            obj = [objDict objectForKey:key];
        }
        if (obj) {
            if ([obj isKindOfClass:[NSString class]]) {
                [values addObject:(NSString*)obj];
            } else if ([obj isKindOfClass:[NSDate class]]) {
                NSDate *dateObj = (NSDate*)obj;
            } else {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    if (self.formatNumbers) {
                        NSNumber *objNumber = (NSNumber*)obj;
                        [values addObject:[NSString stringWithFormat:@"%0.2f", [objNumber doubleValue]]];
                    } else {
                        [values addObject:[obj description]];
                    }
                } else {
                    [values addObject:[obj description]];
                }
            }
        } else {
            NSLog(@"obj for key %@ is nil", key);
        }
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objDict = (NSDictionary*)object;
        NSString *rcoRecordId = [objDict objectForKey:@"rcoRecordId"];
        if (rcoRecordId) {
            [values addObject:[NSString stringWithFormat:@"(%@)", rcoRecordId]];
        }
    } else {
        
    }
    
    NSInteger index = 0;
    
    if (_mainItems) {
        for (NSString *key in _detailFields) {
            
            if (self.detailFieldsName.count == _detailFields.count) {
                NSObject *obj = [object valueForKey:key];
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([self.boolFields containsObject:key]) {
                        NSString *val = @"no";
                        if ([(NSString*)obj boolValue]) {
                            val = @"yes";
                        }
                        
                        [detailValues addObject:[NSString stringWithFormat:@"%@ %@", [self.detailFieldsName objectAtIndex:index], val]];
                    } else {
                        [detailValues addObject:[NSString stringWithFormat:@"%@ %@", [self.detailFieldsName objectAtIndex:index], (NSString*)obj]];
                    }
                } else {
                    [detailValues addObject:[NSString stringWithFormat:@"%@ %@", [self.detailFieldsName objectAtIndex:index], [obj description]]];
                }
                
            } else {
                NSObject *obj = [object valueForKey:key];
                if ([obj isKindOfClass:[NSString class]]) {
                    [detailValues addObject:(NSString*)obj];
                } else if ([obj isKindOfClass:[NSDate class]]) {
                    NSDate *dateObj = (NSDate*)obj;
                } else {
                    if ([obj description]) {
                        [detailValues addObject:[obj description]];
                    } else {
                        [detailValues addObject:@""];
                    }
                }
            }
        }
    }
    
    NSString *text = nil;
    
    if (self.joiningString) {
        text = [values componentsJoinedByString:self.joiningString];
    } else {
        text = [values componentsJoinedByString:@", "];
    }
    
    if (self.showIndexNumber) {
        text = [NSString stringWithFormat:@"%d. %@", (int)(indexPath.row + 1), text];
    }
    
    cell.textLabel.text = text;

    if (_detailFields.count > 0) {
        cell.detailTextLabel.text = [detailValues componentsJoinedByString:@", "];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone; //UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    

    
    if ([self allowMultipleSelection]) {
        if (indexPath.section == 0) {
            if ([self.selectedItems containsObject:object]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else  {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else {
        if ([self selectItem:object]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else  {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    if (self.loadIcon) {
        NSString *iconName = nil;
        if ([self.loadIconPropertyName length]) {
            iconName = [object valueForKey:self.loadIconPropertyName];
            if ([iconName length]) {
                iconName = [NSString stringWithFormat:@"%@.png", iconName];
                cell.imageView.image = [UIImage imageNamed:iconName];
            }
        }
    }
    
    return cell;
}

-(BOOL)selectItem:(id)object {
    if ([self.selectedItem isKindOfClass:[NSString class]] && [object isKindOfClass:[NSString class]]) {
        return [self.selectedItem isEqualToString:object];
    } else if (self.selectedItem && object){
        return (self.selectedItem == object);
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    RCOObject *selectedObject = nil;
    
    if ([self allowMultipleSelection]) {
        if (self.isViewMode) {
            // we should not allow editing when in view mode
            return;
        }
        if (indexPath.section == 0) {
            // we should remove it
            selectedObject = [self.selectedItems objectAtIndex:indexPath.row];
            if ([self.selectedItems containsObject:selectedObject]) {
                // we should remove it from the selected items list
                NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.selectedItems];
                [tmp removeObject:selectedObject];
                self.selectedItems = [NSArray arrayWithArray:tmp];
            }
        } else {
            // we should add it
            selectedObject = [self.itemsFiltered objectAtIndex:indexPath.row];
            if (![self.selectedItems containsObject:selectedObject]) {
                // we should remove it from the selected items list
                NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.selectedItems];
                [tmp addObject:selectedObject];
                self.selectedItems = [NSArray arrayWithArray:tmp];
            }
        }
        
        [tableView reloadData];
        return;
    }
    
    
    if (indexPath.section == 0) {
        if (_mainItems) {
            selectedObject = [self.itemsFiltered objectAtIndex:indexPath.row];
        } else {
            selectedObject = [self.secondItemsFiltered objectAtIndex:indexPath.row];
        }
    } else {
        selectedObject = [self.itemsAssembliesFiltered objectAtIndex:indexPath.row];
    }
    
    if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)] || [self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        if (self.selectDelegate) {
            [self.selectDelegate didAddObject:selectedObject forKey:_key];
        } else {
            [self.addDelegate didAddObject:selectedObject forKey:_key];
        }
    }
    if (DEVICE_IS_IPHONE) {
        if (!self.iPhoneNewLogic) {
            [self cancelPressed:nil];
        }
    } else {
        if (self.isViewControllerPushed) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = [searchBar text];
    
    [self handleSearchForTerm:searchTerm];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm {
  
    if (self.isViewMode) {
        searchBar.text = nil;
        NSString *message = @"List is not in edit mode!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([searchTerm length] == 0) {
        [self resetSearch];
        [self.tableView reloadData];
        return;
    }
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  
    //isSearching = NO;
    //search.text = @"";
    [self resetSearch];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    //isSearching = YES;
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    if ([searchBar.text length] == 0) {
        //isSearching = NO;
        if (self.showEmptyList) {
            self.itemsFiltered = [NSMutableArray array];
        }
    } else {
        //isSearching = YES;
    }
    
    [self.tableView reloadData];
}

-(void)resetSearch {
    self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    if (self.itemsAssemblies) {
        self.itemsAssembliesFiltered = [NSMutableArray arrayWithArray:self.itemsAssemblies];
    }
    
    if (self.showEmptyList) {
        self.itemsFiltered = [NSMutableArray array];
    }

    [self.tableView reloadData];
}

-(void)handleSearchForTerm:(NSString*)searchString {
    if (self.isViewMode) {
        // if is view mode we should not allow to search, is just view
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rcoObjectSearchString CONTAINS[c] %@", searchString];
    
    NSArray *filteredItems = nil;
    if (_mainItems) {
        filteredItems = [self.items filteredArrayUsingPredicate:predicate];
    } else {
        filteredItems = [self.secondItems filteredArrayUsingPredicate:predicate];
    }
    if (_mainItems) {
        self.itemsFiltered = [NSMutableArray arrayWithArray:filteredItems];
    } else {
        self.secondItemsFiltered = [NSMutableArray arrayWithArray:filteredItems];
    }
    
    if ([self.itemsAssemblies count]) {
        NSArray *filteredItems = [self.itemsAssemblies filteredArrayUsingPredicate:predicate];
        self.itemsAssembliesFiltered = [NSMutableArray arrayWithArray:filteredItems];
    }
    
    if (self.showEmptyList) {
        if ([searchString length] == 0) {
            self.itemsFiltered = [NSMutableArray array];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark AddObject Delegate Methods

-(void)didAddObject:(NSObject*)object forKey:(NSString*)key {

}

-(void)didSaveObject:(RCOObject*)object {
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self loadList];
    
    NSInteger index = [self.itemsFiltered indexOfObject:object];
    if (index != NSNotFound) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}


-(void)didCancelObject:(RCOObject*)object {
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark UIAlertViewDelegate 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
}
-(void)loadList {
    
    // Do any additional setup after loading the view from its nib.
    
    {
        if (_predicate) {
            NSSortDescriptor *sd = nil;
            sd = [NSSortDescriptor sortDescriptorWithKey:_sortKey ascending:YES];
            
            self.items = [_aggregate getAllNarrowedBy:_predicate andSortedBy:[NSArray arrayWithObject:sd]];
            
            if (self.sortNumerical) {
                sd = [NSSortDescriptor sortDescriptorWithKey:self.sortNumericalKey ascending:YES comparator:^(id obj1, id obj2) { return [obj1 compare:obj2 options:NSNumericSearch]; }];
                self.items = [self.items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
            }
        } else {
            NSArray *allItems = [_aggregate getAll];
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:_sortKey ascending:!self.sortDescending];

            if (_sortKey) {
                self.items = [allItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
            } else {
                self.items = allItems;
            }
            
            if (self.sortNumerical) {
                sd = [NSSortDescriptor sortDescriptorWithKey:self.sortNumericalKey ascending:YES comparator:^(id obj1, id obj2) { return [obj1 compare:obj2 options:NSNumericSearch]; }];
                self.items = [self.items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
            }
        }
    }
    if (self.showEmptyList) {
        self.itemsFiltered = [NSMutableArray array];
    } else {
        self.itemsFiltered = [NSMutableArray arrayWithArray:self.items];
    }
    
    if ([self.itemsAssemblies count]) {
        self.itemsAssembliesFiltered = [NSMutableArray arrayWithArray:self.itemsAssemblies];
    }
}

-(void)reloadList {
    [self loadList];
    [self.tableView reloadData];
}

@end
