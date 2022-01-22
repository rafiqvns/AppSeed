//
//  RCOValuesListViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 7/26/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddObject.h"
#import "UIViewController+iOS6.h"

typedef enum {
    EditTypeUnknown = 0,
    EditTypeSelect,
    EditTypeRemove
    
} EditType;


@interface RCOValuesListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>{
    NSArray *_items;
    NSString *_key;
}

@property (nonatomic, weak) id <AddObject> selectDelegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) NSArray *propertiesToShow;
@property (nonatomic, assign) BOOL isPushed;
@property (nonatomic, assign) EditType editType;
@property (nonatomic, assign) BOOL showColorSample;
@property (nonatomic, assign) BOOL showColorPicker;
@property (nonatomic, strong) NSString *selectedValue;
@property (nonatomic, strong) NSMutableArray *selectedValues;
@property (nonatomic, assign) BOOL isCurrencyPicker;
@property (nonatomic, assign) BOOL sortByObjectDescription;
@property (nonatomic, strong) NSArray *detailValues;
@property (nonatomic, assign) NSInteger numberOfLines;
@property (nonatomic, assign) BOOL shrinkContentToFit;
@property (nonatomic, assign) BOOL showIndex;
@property (nonatomic, strong) NSString *screenInfo;
@property (nonatomic, assign) BOOL newLogic;
@property (nonatomic, assign) BOOL showClearButton;
@property (nonatomic, assign) BOOL allowMultipleSelections;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil items:(NSArray*)items forKey:(NSString*)key;

-(IBAction)colorPickerButtonPressed:(id)sender;

@end
