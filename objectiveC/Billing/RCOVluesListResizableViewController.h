//
//  RCOVluesListResizableViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 3/6/14.
//  Copyright (c) 2014 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCOVluesListResizableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *sectionNames;

@property (nonatomic, strong) NSArray *values;

@end
