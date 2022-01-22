//
//  CSDAccidentFormsListViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/12/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@interface CSDAccidentFormsListViewController : HomeBaseViewController <AddObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
}

@property (nonatomic, weak) id<RCOSpliterSelectionDelegate> selectionDelegate;
@property (nonatomic, weak) UINavigationController *parentNavController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

-(IBAction)addButtonPressed:(id)sender;
-(IBAction)actionButtonPressed:(id)sender;
-(IBAction)filterButtonPressed:(id)sender;
-(IBAction)viewModeChanged:(id)sender;

@end
