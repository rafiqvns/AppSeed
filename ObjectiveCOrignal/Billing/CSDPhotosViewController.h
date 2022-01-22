//
//  CSDPhotosViewController.h
//  CSD
//
//  Created by .D. .D. on 6/21/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class AccidentVehicleReport;

@interface CSDPhotosViewController : HomeBaseViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AccidentVehicleReport *header;
-(IBAction)syncPhotos:(id)sender;
@end

NS_ASSUME_NONNULL_END
