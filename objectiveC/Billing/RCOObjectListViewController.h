//
//  RCOObjectListViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 7/11/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aggregate.h"
#import "AddObject.h"
#import "UIViewController+iOS6.h"
#import "BaseViewController.h"

@interface RCOObjectListViewController : BaseViewController <UISearchBarDelegate, AddObject, UIAlertViewDelegate>{
    Aggregate *_aggregate;
    NSArray *_fields;
    NSString *_key;
    NSPredicate *_predicate;
    NSString *_sortKey;
    NSArray *_detailFields;
    BOOL _editable;
    BOOL _mainItems;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil aggregate:(Aggregate*)objectAggregate fields:(NSArray*)objectFields forKey:(NSString*)key filterByPredicate:(NSPredicate*)predicate andSortedBy:(NSString*)sortKey;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil aggregate:(Aggregate*)objectAggregate fields:(NSArray*)objectFields detailFields:(NSArray*)detailFields forKey:(NSString*)key filterByPredicate:(NSPredicate*)predicate andSortedBy:(NSString*)sortKey;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil aggregate:(Aggregate*)objectAggregate fields:(NSArray*)objectFields detailFields:(NSArray*)detailFields forKey:(NSString*)key filterByPredicate:(NSPredicate*)predicate andSortedBy:(NSString*)sortKey editable:(BOOL)editable;

@property (nonatomic, weak) id <AddObject> selectDelegate;
@property (nonatomic, assign) BOOL showClearButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *joiningString;
@property (nonatomic, assign) BOOL isViewControllerPushed;
@property (nonatomic, strong) NSArray *detailFieldsName;
@property (nonatomic, strong) NSArray *boolFields;
@property (nonatomic, assign) BOOL sortNumerical;
@property (nonatomic, assign) BOOL sortDescending;
@property (nonatomic, strong) NSString *sortNumericalKey;

@property (nonatomic, assign) BOOL partsFromLibraryList;
@property (nonatomic, assign) BOOL partsFromAssembliesList;
@property (nonatomic, assign) BOOL showColorSample;
@property (nonatomic, assign) BOOL showPartServiceSwitch;
@property (nonatomic, assign) BOOL formatNumbers;

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UIToolbar *editToolbar;

@property (nonatomic, assign) BOOL enableDeleteItem;
@property (nonatomic, assign) BOOL enableAddUserItem;
@property (nonatomic, assign) BOOL showIndexNumber;

@property (nonatomic, strong) NSArray *items;
/*
 for allowing multiple selections we should set selectedItems, it can be an empty array but needs to be different than nil
 */
@property (nonatomic, strong) NSArray *selectedItems;
@property (nonatomic, strong) id selectedItem;

/*
 showEmptyList
 
 is used when showing the list of objects in a popup. The list is being populated as we start tapping in the search input
 */
@property (nonatomic, assign) BOOL showEmptyList;

@property (nonatomic, assign) BOOL showAllUsers;

@property (nonatomic, assign) BOOL isViewMode;

@property (nonatomic, assign) BOOL loadIcon;
@property (nonatomic, strong) NSString *loadIconPropertyName;

@property (nonatomic, assign) BOOL iPhoneNewLogic;
@property (nonatomic, assign) BOOL resetPreviousSelection;

-(IBAction)addButtonPressed:(id)sender;
-(IBAction)editButtonSwitched:(id)sender;
-(void)reloadList;

@end
