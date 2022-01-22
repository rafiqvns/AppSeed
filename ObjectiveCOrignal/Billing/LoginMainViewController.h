//
//  LoginMainViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/4/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "HttpClientOperation.h"

@interface LoginMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, HTTPClientOperationDelegate, HTTPClientOperationDelegate> {
    NSMutableDictionary *_loginParameters;
    BOOL _isEditing;
    NSInteger _numberOfTries;
    NSTimeInterval _tryLoginDate;
    UIInterfaceOrientation _currentOrientation;
    BOOL _isConnecting;
}

@property (nonatomic, strong) IBOutlet UIImageView *themebackground;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *remeberView;
@property (nonatomic, strong) IBOutlet UISwitch *rememberSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *offlineSwitch;
@property (nonatomic, strong) IBOutlet UILabel *rememberLabel;
@property (nonatomic, strong) IBOutlet UILabel *workOfflineLabel;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, assign) bool recordELDLogin;

-(IBAction)switchValueChanged:(id)sender;

@end
