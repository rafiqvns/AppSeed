//
//  CSDInfoViewController.m
//  CSD
//
//  Created by .D. .D. on 11/1/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDInfoViewController.h"
#import "CSDEyeMovementViewController.h"
#import "CSDFormsListViewController.h"
#import "CSDTestViewController.h"
#import "CSDEquipmentViewController.h"
#import "CSDTestInfoViewController.h"
#import "Settings.h"
#import "NSDate+Misc.h"
#import "CSDNotesViewController.h"
#import "TestDataHeader+CoreDataClass.h"
#import "TrainingCompanyAggregate.h"
#import "TrainingCompany+CoreDataClass.h"
#import "DataRepository.h"

#define IndexInfo 0
#define IndexEquip 1
#define IndexPre 2
#define IndexRoad 3
#define IndexEye 4
#define IndexSWP 5
#define IndexProd 6
#define IndexNotes 7
#define IndexVRT 8
#define IndexPAS 9

@interface CSDInfoViewController ()
@property (nonatomic, strong) NSMutableArray *ignoreSaveItems;
@property (nonatomic, assign) BOOL stopLeavingTheScreen;
@property (nonatomic, assign) BOOL initialLoading;
@property (nonatomic, strong) NSMutableArray *controllers;
@property (nonatomic, assign) NSInteger currentControllerIndex;
@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *homeBtn;
@property (nonatomic, strong) UISegmentedControl *segControl;
@property (nonatomic, strong) UIButton *btnControl;

@property (nonatomic, assign) BOOL useTheAutoSaveLogic;
@property (nonatomic, assign) BOOL isDrivingSchool;

@end

@implementation CSDInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.useTheAutoSaveLogic = YES;

    [self checkUserCompanyType];

    NSNumber *isDrivingSchool = [Settings getSettingAsNumber:CSD_COMPANY_DRIVING_SCHOOL];
    
    if ([isDrivingSchool boolValue]) {
        self.isDrivingSchool = YES;
    } else {
        self.isDrivingSchool = NO;
    }

    if (!self.isDrivingSchool) {
        self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                     target:self
                                                                     action:@selector(saveButtonPressed:)];
    }
    
    [self checkLastSaveDateForTestInfoRecord];
    self.controllers = [NSMutableArray array];
    self.currentControllerIndex = 0;
    
    
    self.segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Info",@"Equip", @"Eye", @"Notes", @"Prod", @"PreTrip", @"BTW", @"SWP",  @"VRT", @"PAS", nil]];
    [self.segControl addTarget:self
                   action:@selector(viewModeChanged:)
         forControlEvents:UIControlEventValueChanged];
    self.btnControl = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnControl setFrame:CGRectMake(0, 0, 80, 44)];
    [self.btnControl setTitle:@"Info" forState:UIControlStateNormal];
    [self.btnControl.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    if (DEVICE_IS_IPAD) {
        [self.navigationItem setTitleView:self.segControl];
    } else {
        [self.btnControl addTarget:self action:@selector(buttonControllPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setTitleView:self.btnControl];
    }
    
    // 0
    CSDTestInfoViewController *info = [[CSDTestInfoViewController alloc] initWithNibName:@"CSDTestInfoViewController" bundle:nil];
    info.addDelegate = self;
    [self.controllers addObject:info];
    
    // 1
    CSDEquipmentViewController *e = [[CSDEquipmentViewController alloc] initWithNibName:@"CSDEquipmentViewController" bundle:nil];
    e.addParentMobileRecordId = YES;
    [self.controllers addObject:e];

    // 2
    CSDEyeMovementViewController *ey = nil;
    if (DEVICE_IS_IPHONE) {
        ey = [[CSDEyeMovementViewController alloc] initWithNibName:@"CSDEyeMovementViewControllerNewiPhone" bundle:nil];
    } else {
        ey = [[CSDEyeMovementViewController alloc] initWithNibName:@"CSDEyeMovementViewControllerNew" bundle:nil];
    }
    ey.addParentMobileRecordId = YES;
    [self.controllers addObject:ey];

    // 3
    CSDNotesViewController *notes = [[CSDNotesViewController alloc] initWithNibName:@"CSDNotesViewController" bundle:nil];
    notes.addParentMobileRecordId = YES;
    [self.controllers addObject:notes];

    // 4 prod
    CSDTestViewController *ctrl = [[CSDTestViewController alloc] initWithNibName:@"CSDTestViewController" bundle:nil];
    ctrl.formNumber = TestProd;
    ctrl.addParentMobileRecordId = YES;
    [self.controllers addObject:ctrl];
    
    // 5 Pre trip
    ctrl = [[CSDTestViewController alloc] initWithNibName:@"CSDTestViewController" bundle:nil];
    ctrl.formNumber = TestPreTrip;
    ctrl.addParentMobileRecordId = YES;
    [self.controllers addObject:ctrl];

    // 6 Road
    ctrl = [[CSDTestViewController alloc] initWithNibName:@"CSDTestViewController" bundle:nil];
    ctrl.formNumber = TestBTW;
    ctrl.addParentMobileRecordId = YES;
    [self.controllers addObject:ctrl];
    
    // 7 SWP
    ctrl = [[CSDTestViewController alloc] initWithNibName:@"CSDTestViewController" bundle:nil];
    ctrl.formNumber = TestSWP;
    ctrl.addParentMobileRecordId = YES;
    [self.controllers addObject:ctrl];
    
    // 8 VRT
    ctrl = [[CSDTestViewController alloc] initWithNibName:@"CSDTestViewController" bundle:nil];
    ctrl.formNumber = TestVRT;
    ctrl.addParentMobileRecordId = YES;
    [self.controllers addObject:ctrl];

    // 9 BUS
    ctrl = [[CSDTestViewController alloc] initWithNibName:@"CSDTestViewController" bundle:nil];
    ctrl.formNumber = TestBusEval;
    ctrl.addParentMobileRecordId = YES;
    [self.controllers addObject:ctrl];

    
    info.listeners = [NSArray arrayWithArray:self.controllers];
    
    self.homeBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home", nil)
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(homeButtonTapped:)];
    self.navigationItem.leftBarButtonItem = self.homeBtn;
    
    [self.segControl setSelectedSegmentIndex:0];
    self.initialLoading = YES;
    if (DEVICE_IS_IPAD) {
        [self viewModeChanged:self.segControl];
    } else {
        [self viewModeChanged:[NSNumber numberWithInteger:0]];
    }
    
    self.ignoreSaveItems = [NSMutableArray array];
}

-(IBAction)buttonControllPressed:(UIButton*)btn {
    
    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (!parentMobileRecordId.length && !self.initialLoading) {
        //[self showSimpleMessage:@"Please save Class first!"];
        [self showSimpleMessage:@"Please save Info first!"];
        return;
    }

    NSDate *startDate = [Settings getSettingAsDate:CSD_TEST_INFO_START_DATE];
    if (!startDate && !self.initialLoading) {
        //[self showSimpleMessage:@"Please start Class first!"];
        [self showSimpleMessage:@"Please start Info first!"];
        return;
    }
        
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[UIFont systemFontOfSize:20] forKey:NSFontAttributeName];
    [dict setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:@"Otions"
                                                              attributes:dict];
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Options", nil)
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    //[al setValue:att forKey:@"attributedTitle"];
    
    NSArray *options = [NSArray arrayWithObjects:@"Info",@"Equip", @"Eye", @"Notes", @"Prod", @"PreTrip", @"BTW", @"SWP",  @"VRT", @"PAS", nil];
    
    for (NSString *option in options) {
        UIAlertAction* action = [UIAlertAction actionWithTitle:option
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
            NSInteger index = [options indexOfObject:action.title];
            [self viewModeChanged:[NSNumber numberWithInteger:index]];
            [self.btnControl setTitle:action.title forState:UIControlStateNormal];
                                                           }];
        [al addAction:action];
    }
    
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                        // we should select back
    }];
    [al addAction:cancelAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(void)checkUserCompanyType {
    // we need to detect if a companty is a driving school or not
    NSString *loggedInUserCompany = [Settings getSetting:CLIENT_COMPANY_NAME];
    TrainingCompanyAggregate *agg = (TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    TrainingCompany *tc = [agg getTrainingCompanyWithName:loggedInUserCompany];
    if (tc) {
        if ([tc.drivingSchool boolValue]) {
            [Settings setSetting:[NSNumber numberWithBool:YES] forKey:CSD_COMPANY_DRIVING_SCHOOL];
        } else {
            [Settings setSetting:[NSNumber numberWithBool:NO] forKey:CSD_COMPANY_DRIVING_SCHOOL];
        }
    } else {
        [Settings resetKey:CSD_COMPANY_DRIVING_SCHOOL];
    }
    [Settings save];
}

-(void)checkLastSaveDateForTestInfoRecord {
    NSDate *lastDateSaved = [Settings getSettingAsDate:CSD_TEST_INFO_MOBILE_RECORD_ID_DATE];
    if (lastDateSaved) {
        // 08.11.2019 we should check if is the same date as the current date. If not we should reset the test info so we don't let them to add linked recprds for other tests
        if ([lastDateSaved compare:[[NSDate date] dateAsDateWithoutTime]] == NSOrderedSame) {
            // is the same day so we should leave it like that
        } else {
            // we should reset the date
            [Settings resetKey:CSD_TEST_INFO_MOBILE_RECORD_ID_DATE];
            [Settings save];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.progressHUD hide:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UIViewController*)getViewForIndex:(NSInteger)index {
    return [self.controllers objectAtIndex:index];
}

-(NSString*)getScreenNameForIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"Info";
            //return @"Class Info";
        case 1:
            return @"Equipment";
        case 2:
            return @"Eye Movement";
        case 3:
            return @"Notes";
        case 4:
            return @"Production";
        case 5:
            return @"Pre Trip";
        case 6:
            return @"BTW";
        case 7:
            return @"SWP";
        case 8:
            return @"VRT";
        case 9:
            return @"PAS";
    }
    return nil;
}


-(void)checkLeaveTheScreen:(UIViewController*)controller {
    NSArray *btns = controller.navigationItem.rightBarButtonItems;
    
    NSInteger index = [self.controllers indexOfObject:controller];
    NSString *title = [self getScreenNameForIndex:index];
    
    if (btns.count == 0) {
        NSLog(@"");
        // 08.11.2019 the screen was not fully loaded
        if (![self.ignoreSaveItems containsObject:controller]) {
            [self.ignoreSaveItems addObject:controller];
        }
        [self homeButtonTapped:nil];
        return;
    }
    
    for (UIBarButtonItem *btn in btns) {
        if ([btn.description containsString:@"save"]) {
            if (btn.enabled) {
                NSString *msg = [NSString stringWithFormat:@"%@ is not saved. Changes will be lost. Do you want to continue?", title] ;
                UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                            message:msg
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                    if (![self.ignoreSaveItems containsObject:controller]) {
                        [self.ignoreSaveItems addObject:controller];
                    }
                    [self homeButtonTapped:nil];
                    self.stopLeavingTheScreen = NO;
                                                                   }];
                
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                    // we should select back
                    self.stopLeavingTheScreen = YES;
                    [self homeButtonTapped:nil];
                }];
                [al addAction:cancelAction];
                [al addAction:yesAction];
                [self presentViewController:al animated:YES completion:nil];
            } else {
                // is not enabled
                if (![self.ignoreSaveItems containsObject:controller]) {
                    [self.ignoreSaveItems addObject:controller];
                }
                [self homeButtonTapped:nil];
            }
        } else {
            // we should put it there just anyway
            if (![self.ignoreSaveItems containsObject:controller]) {
                [self.ignoreSaveItems addObject:controller];
            }
            [self homeButtonTapped:nil];
        }
    }
}

-(IBAction)saveButtonPressed:(UIBarButtonItem*)sender {
    [sender setEnabled:NO];

    if (sender) {
        // we should show the message just in the case when we aer tapping on the button and not when is called from a different place with "nil"...
        NSInteger index = self.segControl.selectedSegmentIndex;
        NSString *title = [self getScreenNameForIndex:index];
        UIViewController<CSDSelectObject> *ctrl = [self.controllers objectAtIndex:index];
        if ([ctrl CSDInfoCanSelectScreen]) {
            // 19.02.2020 the test was not changed so we should not show any message here
            NSLog(@"");
            NSString *msg = [NSString stringWithFormat:@"No changes were made to:\n\n %@", title];
            [self showSimpleMessageAndHide:msg];
        } else {
            NSString *msg = [NSString stringWithFormat:@"Saving %@...", title];
            [self showSimpleMessageAndHide:msg];
        }
    }
    
    for (NSInteger i = 0; i < self.controllers.count; i++) {
        UIViewController<CSDSelectObject> *ctrl = [self.controllers objectAtIndex:i];
        [ctrl CSDSaveRecordOnServer:YES];
    }
    [sender setEnabled:YES];
    
    /*
     07.02.2020 we should not reset here, we should be able to see th preview
     
    NSDate *endDateTime = [Settings getSettingAsDate:CSD_TEST_INFO_STOP_DATE];
    if (endDateTime) {
        [Settings resetKey:CSD_TEST_INFO_STOP_DATE];
        [Settings resetKey:CSD_TEST_INFO_START_DATE];
        [Settings resetKey:CSD_TEST_INFO_MOBILE_RECORD_ID];
        [Settings save];
    }
    */
}

-(IBAction)homeButtonTapped:(id)sender {
    NSString *msg = nil;
    
    if (self.isDrivingSchool) {
        msg = @"Do you want to leave the Class?";
    } else {
        msg = @"Are you finished with the Class?";
    }
    
    // 23.01.2020  the message was "ugly"
    msg = @"Do you want to leave the Class?";

    
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:msg
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        if (self.isDrivingSchool) {
            [self leaveTheScreen];
        } else {
            // 23.01.2020 we need to force save especially for the end functionality
            [self performSelector:@selector(saveAndLeaveTheScreen) withObject:nil afterDelay:0.01];
        }
                                                       }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
    }];
    
    [al addAction:cancelAction];
    [al addAction:yesAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(void)saveAndLeaveTheScreen {
    self.progressHUD.labelText = @"Saving data, please wait...";
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];
    [self performSelector:@selector(saveAndLeaveTheScreen2) withObject:nil afterDelay:0.1];
}

-(void)saveAndLeaveTheScreen2 {
    [self saveButtonPressed:nil];
    [super homePressed:self.homeBtn];
}

-(void)leaveTheScreen {
    for (NSInteger i = 0; i < self.controllers.count; i++) {
        UIViewController<CSDSelectObject> *ctrl = [self.controllers objectAtIndex:i];
        BOOL screenSaved = [ctrl CSDInfoCanSelectScreen];
        if (!screenSaved) {
            if (self.useTheAutoSaveLogic) {
                //10.12.2019 we should save everything
                [ctrl CSDSaveRecordOnServer:YES];
            } else {
                NSString *screenTitle = [ctrl CSDInfoScreenTitle];
                [self showSimpleMessage:[NSString stringWithFormat:@"Please save first:\n\n%@", screenTitle]];
                return;
            }
        }
    }
    [super homePressed:self.homeBtn];
}

-(IBAction)homeButtonTappedOld:(id)sender {
    if (self.ignoreSaveItems.count == self.controllers.count) {
        [super homePressed:sender];
        return;
    }
    
    for (NSInteger i = 0; i < self.controllers.count; i++) {
        if (self.stopLeavingTheScreen) {
            self.stopLeavingTheScreen = NO;
            self.ignoreSaveItems = [NSMutableArray array];
            [super homePressed:sender];
            return;
        }
        UIViewController *ctrl = [self.controllers objectAtIndex:i];
        if ([self.ignoreSaveItems containsObject:ctrl]) {
            continue;
        }
        [self checkLeaveTheScreen:ctrl];
        break;
    }
}

-(NSArray*)getSaveSignatureMessage {
    NSMutableArray *titles = [NSMutableArray array];
    for (HomeBaseViewController<CSDSelectObject> *currentController  in self.controllers) {
        if ([currentController respondsToSelector:@selector(CSDNeedsToSign)]) {
            if ([currentController CSDNeedsToSign]) {
                NSString *title = [currentController CSDInfoScreenTitle];
                if (title) {
                    [titles addObject:title];
                }
            }
        }
    }
    NSLog(@"");
    return titles;
}

-(IBAction)viewModeChanged:(id)senderParam {
    
    UISegmentedControl* sender = nil;
    
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        sender = (UISegmentedControl*)senderParam;
    }
    
    NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
    if (!parentMobileRecordId.length && !self.initialLoading) {
        //[self showSimpleMessage:@"Please save Class first!"];
        [self showSimpleMessage:@"Please save Info first!"];

        [sender setSelectedSegmentIndex:0];
        return;
    }

    NSDate *startDate = [Settings getSettingAsDate:CSD_TEST_INFO_START_DATE];
    if (!startDate && !self.initialLoading) {
        //[self showSimpleMessage:@"Please start Class first!"];
        [self showSimpleMessage:@"Please start Info first!"];
        [sender setSelectedSegmentIndex:0];
        return;
    }
    
    HomeBaseViewController<CSDSelectObject> *currentController = [self.controllers objectAtIndex:self.currentControllerIndex];
    BOOL canSelectScreen = [currentController CSDInfoCanSelectScreen];
    // 10.12.2019 we should allow schaning the "tabs"
    if (self.useTheAutoSaveLogic) {
        canSelectScreen = YES;
    }

    if (canSelectScreen || self.initialLoading) {
        [self viewModeChangedOld:senderParam];
        if (self.initialLoading) {
            self.initialLoading = NO;
        }
    } else {
        [sender setSelectedSegmentIndex:self.currentControllerIndex];
        NSString *screenTitle = [currentController CSDInfoScreenTitle];
        [self showSimpleMessage:[NSString stringWithFormat:@"Please save first:\n\n%@", screenTitle]];
    }
}

-(IBAction)viewModeChangedOld:(id)senderParam {
    
    UISegmentedControl *sender = nil;
    
    if ([senderParam isKindOfClass:[UISegmentedControl class]]) {
        sender = (UISegmentedControl*)senderParam;
    }
    
    HomeBaseViewController<CSDSelectObject> *currentController = [self.controllers objectAtIndex:self.currentControllerIndex];
    [currentController.view endEditing:YES];
    [currentController unregisterKeyboardEvents];
    if (self.initialLoading) {
        NSLog(@"");
    } else {
        [currentController CSDSaveRecordOnServer:NO];
    }
    
    UIViewController *controller = nil;
    UIView *v = nil;
    NSMutableArray *buttons = nil;
    NSInteger screenIndex = 0;
    
    if (DEVICE_IS_IPAD) {
        screenIndex = sender.selectedSegmentIndex;
    } else {
        screenIndex = [(NSNumber*)senderParam integerValue];
    }

    controller = [self.controllers objectAtIndex:screenIndex];
    self.currentControllerIndex = screenIndex;

    v = controller.view;

    NSLog(@"View = %@", v);
    buttons = [NSMutableArray arrayWithArray:controller.navigationItem.rightBarButtonItems];
    
    for (UIView *view in self.view.subviews) {
        [view setHidden:NO];
    }

    // 10.12.2019 we should have a "master Save" button
    if (!self.isDrivingSchool) {
        // 27.12.2019 in the case when is NOT driving school then we should add a "global" save button
        [buttons addObject:self.saveBtn];
    }
    [self.navigationItem setRightBarButtonItems:buttons];
    
    if (controller) {
        [self addChildViewController:controller];
        [self.view addSubview:v];
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        v.frame = frame;
        [controller didMoveToParentViewController:self];
    } else {
        for (UIView *view in self.view.subviews) {
            [view setHidden:YES];
        }
    }
    [(HomeBaseViewController*)controller unRegisterCallbacks];
    [(HomeBaseViewController*)controller registerKeyboardEvents];
    if ([controller respondsToSelector:@selector(CSDInfoDidSelectObject:)]) {
        if (!self.initialLoading) {
            NSString *parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
            [controller performSelectorOnMainThread:@selector(CSDInfoDidSelectObject:) withObject:parentMobileRecordId waitUntilDone:YES];
        }
    }
}

#pragma mark AddObject delegate

-(void)didSaveObject:(RCOObject *)object {
    if (object) {
        [self saveButtonPressed:nil];
    }
}

@end
