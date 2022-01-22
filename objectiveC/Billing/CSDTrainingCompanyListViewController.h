//
//  CSDTrainingCompanyListViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/12/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@interface CSDTrainingCompanyListViewController : HomeBaseViewController <AddObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
}

@property (nonatomic, weak) id<RCOSpliterSelectionDelegate> selectionDelegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

-(IBAction)reloadButtonPressed:(id)sender;

@end
