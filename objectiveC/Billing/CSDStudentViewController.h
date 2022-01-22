//
//  CSDStudentViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/16/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"
#import "AccidentVehicleReport+CoreDataClass.h"
#import "ServerManager.h"
#import "HelperUtility.h"

@class User;
@class TrainingCompany;

@interface CSDStudentViewController : HomeBaseViewController <AddObject, UITextFieldDelegate> {
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) TrainingCompany *company;
@property (nonatomic, strong) NSString *userItemType;
@property (nonatomic, assign) BOOL showGroupActions;



-(IBAction)deleteButtonPressed:(id)sender;
-(IBAction)viewChanged:(id)sender;

@end
