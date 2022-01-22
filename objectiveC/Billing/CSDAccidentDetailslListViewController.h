//
//  CSDAccidentDetailslListViewControllerr.h
//  MobileOffice
//
//  Created by .D. .D. on 6/12/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"
#import "AccidentVehicleReport+CoreDataClass.h"

@class AccidentVehicleReport;

@interface CSDAccidentDetailslListViewController : HomeBaseViewController <AddObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
}

@property (nonatomic, weak) id<RCOSpliterSelectionDelegate> selectionDelegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AccidentVehicleReport *accident;
@property (nonatomic, assign) AccidentRecordType recordType;

-(IBAction)addButtonPressed:(id)sender;

@end
