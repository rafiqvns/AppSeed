//
//  CSDTestInfoViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/16/2019.
//  Copyright (c) 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"
#import "CSDTestSelectObject.h"


@interface CSDTestInfoViewController : HomeBaseViewController <AddObject, UITextFieldDelegate, UIDocumentBrowserViewControllerDelegate, CSDSelectObject> {
    
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *startBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stopBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *groupBtn;
@property (nonatomic, strong) NSArray<UIViewController*> *listeners;

-(IBAction)addButtonPressed:(id)sender;
-(IBAction)infoButtonPressed:(id)sender;
-(IBAction)startButtonPressed:(id)sender;
-(IBAction)stopButtonPressed:(id)sender;
-(IBAction)groupButtonPressed:(id)sender;
@end
