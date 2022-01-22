//
//  CSDScoresFilterViewController.h
//  CSD
//
//  Created by .D. .D. on 12/23/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface CSDScoresFilterViewController : HomeBaseViewController<AddObject, UITableViewDelegate, UITableViewDataSource> {
    
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *fromBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *toBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *studentBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *testBtn;
@property (nonatomic, strong) NSArray *testsSCores;
@property (nonatomic, strong) User *student;
@property (nonatomic, strong) NSString *studentId;

-(IBAction)fromDateButtonPressed:(id)sender;
-(IBAction)toDateButtonPressed:(id)sender;
-(IBAction)studentButtonPressed:(id)sender;
-(IBAction)testButtonPressed:(id)sender;
-(IBAction)sortScoresChanged:(id)sender;
-(IBAction)chartButtonPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
