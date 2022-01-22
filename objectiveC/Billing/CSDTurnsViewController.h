//
//  CSDTurnsViewController.h
//  CSD
//
//  Created by .D. .D. on 6/21/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN

@class User;

@interface CSDTurnsViewController : HomeBaseViewController <MFMailComposeViewControllerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet UISegmentedControl *segController;
@property (nonatomic, strong) NSString *testMobileRecordId;
@property (nonatomic, strong) NSDate *testDateTime;
@property (nonatomic, strong) User *student;
@property (nonatomic, strong) User *instructor;
@property (nonatomic, strong) NSDictionary *values;

-(IBAction)turnsChanged:(id)sender;

@end

NS_ASSUME_NONNULL_END
