//
//  CSDDashboardViewController.h
//  CSD
//
//  Created by .D. .D. on 12/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSDDashboardViewController : HomeBaseViewController<AddObject, UITableViewDelegate, UITableViewDataSource> {
    
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *fromBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *toBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *studentBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *testBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *filterButton;

-(IBAction)fromDateButtonPressed:(id)sender;
-(IBAction)toDateButtonPressed:(id)sender;
-(IBAction)studentButtonPressed:(id)sender;
-(IBAction)testButtonPressed:(id)sender;
-(IBAction)sortScoresChanged:(id)sender;
-(IBAction)filterButtonPressed:(id)sender;
-(IBAction)filterButtonPressedNew:(id)sender;

@end

NS_ASSUME_NONNULL_END
