//
//  LaunchMenuViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 4/14/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "LaunchMenuViewController.h"
#import "UIViewController+iOS6.h"

#import "DataRepository.h"
#import "LoginMainViewController.h"
#import "BillingAppDelegate.h"

#import "TestViewController.h"

#import "UIColor+TKCategory.h"

#import "Settings.h"

#import "CSDTrainingCompanyListViewController.h"

#import "CSDEyeMovementViewController.h"
#ifndef APP_CSD_ACCIDENT
#import "CSDInfoViewController.h"
#endif

#import "UsersViewController.h"

#import "CSDFormsListViewController.h"
#import "CSDAccidentFormsListViewController.h"
#import "CSDScoresViewController.h"
#import "CSDDashboardViewController.h"
#import "UserGroupsListViewController.h"

#define kSyncProgressRecordLabel 20

#define kSyncIndex 15
#define kSyncNowIndex 56
#define kCSDClassCFormIndex 80
#define kCSDTrainingStudentsIndex 81
#define kCSDTrainingInstructorsIndex 82
#define kBillOfLadingIndex 83
#define kCSDEyeIndex 87
#define kCSDPreTripFormIndex 88
#define kCSDBusFormIndex 89
#define kCSDAccidentFormIndex 90
#define kCSDTrainingCompanyIndex 92
#define kUserGroupsIndex 94
#define kUsersIndex 95
#define kCSDTestIndex 102
#define kCSDScoresIndex 107
#define kCSDCharts 108
#define kCSDDashboard 109
#define kCSDMapsIndex 110

#define TAG_FULL_SYNC 1002
#define TAG_LOGOUT 1003

#define kNumberOfRows @"numberOfRows"
#define kNumberOfColumns @"numberOfColumns"
#define kIconWidth @"iconWidth"
#define kIconHeight @"iconHeight"
#define kStartX @"startX"
#define kStartY @"startY"

#define kSyncNowRight @"Mobile-DisplaySyncNow"

#define PageNotSet -1

static LaunchMenuViewController *objShared;

@implementation DACircularProgressView (DACircularProgressView_Observer)

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:kSyncProgress] )
    {
        NSNumber *p = [change objectForKey:NSKeyValueChangeNewKey];
        NSLog(@">>>>Progress = %@", p);
        if (p.doubleValue >= self.progress) {
            [self setProgress:[p floatValue]];
        }
    }
}
@end

@implementation UILabel (UILLabel_Observer)

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kObjectsSynced] ||
       [keyPath isEqualToString:kObjectsToSync] ||
       ([keyPath isEqualToString:kSyncNetworkStatus] && self.tag == 1) )
    {
        NSNumber *objectsSynced = [[DataRepository sharedInstance].statusDict objectForKey:kObjectsSynced];
        NSNumber *objectsToSync = [[DataRepository sharedInstance].statusDict objectForKey:kObjectsToSync];
        
        if ([[DataRepository sharedInstance] workOffline] && ![[DataRepository sharedInstance] forcedSync]) {
            self.text = @"Records:\nOffline";
        } else if( [DataRepository sharedInstance].networkStatus == AFNetworkReachabilityStatusNotReachable) {
            self.text = @" \nNetwork";
        }
        else if( [DataRepository sharedInstance].syncStatus >= SYNC_STATUS_COMPLETE){
            self.text = @"All records\nupdated";
        }
        else if( [objectsSynced unsignedIntegerValue] < [objectsToSync unsignedIntegerValue] ) {
            self.text = [NSString stringWithFormat:@"records:\n%@/%@", objectsSynced, objectsToSync];
        }
        else if( [DataRepository sharedInstance].syncStatus < SYNC_STATUS_REQUEST_COMPLETE){
            self.text = @"Records:\nrequesting";
        }
        else {
            self.text = @"All records\nupdated";
        }
    }
    else if([keyPath isEqualToString:kFilesSynced] ||
            [keyPath isEqualToString:kFilesToSync] ||
            [keyPath isEqualToString:kSyncNetworkStatus] )
    {
        NSNumber *filesSynced = [[DataRepository sharedInstance].statusDict objectForKey:kFilesSynced];
        NSNumber *filesToSync = [[DataRepository sharedInstance].statusDict objectForKey:kFilesToSync];
        
        if ([[DataRepository sharedInstance] workOffline] && ![[DataRepository sharedInstance] forcedSync]) {
            self.text = @"Pictures:\nOffline";
        } else if( [DataRepository sharedInstance].networkStatus == AFNetworkReachabilityStatusNotReachable) {
            self.text = @"Unavailable\n ";
        }
        else if( [DataRepository sharedInstance].syncStatus >= SYNC_STATUS_COMPLETE){
            self.text = @"All pictures\nupdated";
        }
        else if( [filesSynced unsignedIntegerValue] < [filesToSync unsignedIntegerValue] ) {
            self.text = [NSString stringWithFormat:@"pictures:\n%@/%@", filesSynced, filesToSync];
        }
        else if( [DataRepository sharedInstance].syncStatus < SYNC_STATUS_CONTENT){
            self.text = @"Pictures:\nqueuing";
        }
        else if( [DataRepository sharedInstance].syncStatus < SYNC_STATUS_CONTENT_COMPLETE){
            self.text = @"Pictures:\nupdating";
        }
        else {
            self.text = @"All pictures\nupdated";
        }
    }
}
@end

@interface LaunchMenuViewController (Private)

- (void)configureMainScreenForiPhone:(BOOL)isPhone orientation:(BOOL)isPortrait;
- (void)openSettingsViewController;
- (void)loadTheme;
- (NSArray*)loadRights:(BOOL)isIphone;
- (void)loadMenuItems;
- (void)scrollToCurrentPage:(UIInterfaceOrientation)orientation;
- (void)scrollBackgroundPages;
@end

@interface LaunchMenuViewController()
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) NSNumber *homeTappingOption;
@property (nonatomic, strong) UIAlertView *logoutAlert;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, strong) NSString *lastProgressStatus;
@property (nonatomic, strong) NSString *badgeStr;
@property (nonatomic, strong) UIAlertController *al;

@end

@implementation LaunchMenuViewController

@synthesize portraitView;
@synthesize landscapeView;
@synthesize portraitScroll;
@synthesize portraitControl;

@synthesize cpLandscape=_cpLandscape;
@synthesize cpPortrait=_cpPortrait;

@synthesize recordLabelLandscape=_recordLabelLandscape, recordLabelPortrait=_recordLabelPortrait;
@synthesize fileLabelLandscape=_fileLabelLandscape, fileLabelPortrait=_fileLabelPortrait;

@synthesize mTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (LaunchMenuViewController *)sharedInstance
{
    if(objShared == nil)
    {
        objShared = [[LaunchMenuViewController alloc] initWithNibName:@"LaunchMenuViewController" bundle:nil];
    }
    return  objShared;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    _menuItems = nil;
    _menuItemsTags = nil;
    
    for (int i = 0; i < [_viewsArrayPortrait count]; i++) {
        UIView *view = (UIView*)[_viewsArrayPortrait objectAtIndex:i];
    }
    _viewsArrayPortrait = nil;
    
    for (int i = 0; i < [_viewsArrayLandscape count]; i++) {
        UIView *view = (UIView*)[_viewsArrayLandscape objectAtIndex:i];
    }
    _viewsArrayLandscape = nil;
    
    self.cpLandscape = nil;
    self.cpPortrait = nil;
                                                                                        
    self.recordLabelPortrait=nil;
    self.recordLabelLandscape=nil;
    self.fileLabelPortrait=nil;
    self.fileLabelLandscape=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"themeChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadMenuItems" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadInvoices" object:nil];
    
    if (0) {
        //[self.popoverCtrl dismissPopoverAnimated:NO];
    }
}

-(void)syncFinished:(NSNotification*)notification {
    [self.cpPortrait setProgress:1.0];
    [self.cpLandscape setProgress:1.0];
}

#pragma mark - View lifecycle

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    _viewsArrayPortrait = [NSMutableArray new];
    _viewsArrayLandscape = [NSMutableArray new];
    
    _currentPage = PageNotSet;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTheme) name:@"themeChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMenuItems:) name:@"loadMenuItems" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPreviousCommand) name:@"selectPreviousCommand" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBackground) name:@"loadBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeTapped:) name:@"homeTapped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInvoices:) name:@"loadInvoices" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadParts:) name:@"loadParts" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogin:) name:NotificationShowLoginScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncFinished:) name:NotificationSynchronizationFinised object:nil];

    BillingAppDelegate *app = (BillingAppDelegate*) [[UIApplication sharedApplication] delegate];

    UIViewController *currentController = app.window.rootViewController;

    self.rootViewController = currentController;
    [self updateBackgroundImage];
    
    
    
    
    
}

-(void)updateBackgroundImage {
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    if ([targetName isEqualToString:@"Water"]) {
        
        NSString *userSubType = [Settings getSetting:USER_SUB_TYPE];
        BOOL isWorker = NO;
        if ([userSubType isEqualToString:UserTypeWorker]) {
            isWorker = YES;
        }
        UIImage *img = nil;
        if (!isWorker && userSubType) {
            img = [UIImage imageNamed:@"WaterAppBg3.jpg"];
        } else {
            img = [UIImage imageNamed:@"WaterAppBg4.jpeg"];
        }
        self.bgImageView.image = img;
        [self.bgImageView setBackgroundColor:[UIColor lightGrayColor]];
    }
}

-(BOOL)isWaterApp {
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    if ([targetName isEqualToString:@"Water"]) {
        return YES;
    }
    return NO;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.landscapeView = nil;
    self.portraitView = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

        UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
        if (size.width > size.height) {
            orientation = UIInterfaceOrientationLandscapeLeft;
        }
        
        [self doRotateToInterfaceOrientation:orientation duration:0];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.isVisible = YES;
    
    BillingAppDelegate *app = (BillingAppDelegate*) [[UIApplication sharedApplication] delegate];
    [app setCurrentButton:@""];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if( ! [[DataRepository sharedInstance] isLoggedIn] ) {
        [self performSelector:@selector(showLogin:) withObject:nil afterDelay:0.3];
    }
    
    if([[DataRepository sharedInstance] isLoggedIn] ) {
        
    }
    
    [self updateBackgroundImage];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isVisible = NO;
}

-(void)loadBackground {
    [self updateBackgroundImage];
}

- (void)selectPreviousCommand {
}

- (void)showLogin:(NSNotification*)notification {
    UIViewController *loginCtrl = nil;
    NSNumber *obj = notification.object;
    loginCtrl = [[LoginMainViewController alloc] initWithNibName:@"LoginMainViewController" bundle:nil];
    ((LoginMainViewController *)loginCtrl).recordELDLogin = [obj boolValue];

    loginCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:loginCtrl animated:YES completion:nil];
}

- (void)reloadMenuItems:(NSNotification*)notification {
    
    if (self.recordLabelPortrait.text) {
        self.lastProgressStatus = self.recordLabelPortrait.text;
    }
    
    for (int i = 0; i < [_viewsArrayPortrait count]; i++) {
        UIView *view = (UIView*)[_viewsArrayPortrait objectAtIndex:i];
        [view removeFromSuperview];
    }
    [_viewsArrayPortrait removeAllObjects];
    
    for (int i = 0; i < [_viewsArrayLandscape count]; i++) {
        UIView *view = (UIView*)[_viewsArrayLandscape objectAtIndex:i];
        [view removeFromSuperview];
    }
    [_viewsArrayLandscape removeAllObjects];
    
    NSArray *subviews = [self.portraitScroll subviews];
    
    for (int i = 0; i < [subviews count]; i++) {
        UIView *view = (UIView*)[subviews objectAtIndex:i];
        [view removeFromSuperview];
    }
    
    _menuItems = nil;
    _menuItemsTags = nil;
    
    [self loadMenuItems];
    
    NSNumber *showControls = notification.object;

    if ([showControls boolValue]) {
        self.portraitScroll.hidden = NO;
        self.portraitControl.hidden = NO;
    }
    
 
    
    
    [self getStudents];
    
    
}

- (void)getStudents {
    
    [[NSUserDefaults standardUserDefaults] setValue:@"asda 1s" forKey:@"testkk"];
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *token = [Settings getSetting:USER_ACCESS_TOKEN];
    
    
    
    
    [[ServerManager sharedManager] getUsersWithType:token withType:@"students/" success:^(id responseObject) {
        
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self getCompanies];
            });
        });
        
        NSDictionary *resp = responseObject;
        if ([HelperSharedManager isCheckNotNULL:resp]) {
            
            NSArray *students = [resp valueForKey:@"results"];
            
            
            
            if ([HelperSharedManager isCheckNotNULL:students]) {
                
                NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES];
                
                
                NSArray *studentsSorted = [NSMutableArray arrayWithArray:[students sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
                
                
                for( NSDictionary * studentDict in studentsSorted) {
                    
                    
                    [self createNewStudent:studentDict userType:kUserTypeStudent];
                }
            }
        }
        
        
        
    } failure:^(NSString *failureReason, NSInteger statusCode) {
        
        NSLog(@"Failure %@", failureReason);
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        
    }];
}

- (void)getInstructors {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *token = [Settings getSetting:USER_ACCESS_TOKEN];
    
    
    
    
    [[ServerManager sharedManager] getUsersWithType:token withType:@"users/" success:^(id responseObject) {
        
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
            });
        });
        
        NSDictionary *resp = responseObject;
        if ([HelperSharedManager isCheckNotNULL:resp]) {
            
            NSArray *students = [resp valueForKey:@"results"];
            
            
            if ([HelperSharedManager isCheckNotNULL:students]) {
                
                NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES];
                
                
                NSArray *studentsSorted = [NSMutableArray arrayWithArray:[students sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
                for( NSDictionary * studentDict in studentsSorted) {
                    [self createNewStudent:studentDict userType:kUserTypeInstructor];
                }
            }
        }
        
        
        
    } failure:^(NSString *failureReason, NSInteger statusCode) {
        
        NSLog(@"Failure %@", failureReason);
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        
    }];
}

- (void) createNewStudent: (NSDictionary *) student userType: (NSString *) userType {
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *info = [student valueForKey:@"info"];
            
             
            
            Aggregate *aggUser = [[DataRepository sharedInstance] getAggregateForClass:userType];
            
            TrainingDriverStudentAggregate *agg = (TrainingDriverStudentAggregate*)[[DataRepository sharedInstance] getAggregateForClass:userType];
            
//            TrainingDriverStudentAggregate *aggUser = (TrainingDriverStudentAggregate*)[self aggregate];
            
            
            NSDictionary *company;
            NSString *driverLicenseNumber = @"";
            NSString *driverLicenseState = @"";
            
            if ([HelperSharedManager isCheckNotNULL:info]) {
                
                company = [info objectForKey:@"company"];
                driverLicenseState = [info objectForKey:@"driver_license_state"];
                driverLicenseNumber = [info valueForKey:@"driver_license_number"];
                
                
                
                if ([HelperSharedManager isCheckNotNULL:driverLicenseNumber]
                    && [HelperSharedManager isCheckNotNULL:driverLicenseNumber] ) { // Ensure license number and state are not null
                    
                    User *user = nil;
                    
//                    if ([userType isEqualToString:kUserTypeStudent]) {
//                        user = [agg getUserWithdDriverLicenseNumber:driverLicenseNumber andState:driverLicenseState];
//                    }
                    
                    user = [agg getAnyUserWithEmail: [student objectForKey:@"email"]];
                    
                    
                    
                    
                    User *usr = nil;
                    if (!user) {
                        
                        usr = (User*)[aggUser createNewObject];
                        
                        if ([HelperSharedManager isCheckNotNULL:[student objectForKey:@"first_name"]]) {
                            
                            usr.firstname = [student objectForKey:@"first_name"];
                        } else {
                            usr.firstname = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[student objectForKey:@"last_name"]]) {
                            
                            usr.surname = [student objectForKey:@"last_name"];
                        } else {
                            usr.surname = @"";
                        }
                        
                        
                        
                        
                        NSString *idObj =[NSString stringWithFormat:@"%@", [student valueForKey:@"id"]];
                        
//                        usr = (User*)[aggUser createNewObject];
                        
                        usr.active = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"address1"]]) {
                            
                            usr.address1 = [info objectForKey:@"address1"];
                        } else {
                            usr.address1 = @"";
                        }
                        
                        
                        //                active = nil;
                        //                address1 = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"address2"]]) {
                            
                            usr.address2 = [info objectForKey:@"address2"];
                        } else {
                            usr.address2 = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"budget"]]) {
                            
                            usr.address2 = [info objectForKey:@"budget"];
                        } else {
                            usr.address2 = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category1_name"]]) {
                            
                            usr.category1Name = [info objectForKey:@"category1_name"];
                        } else {
                            usr.category1Name = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category1_value"]]) {
                            
                            usr.category1Value = [info objectForKey:@"category1_value"];
                        } else {
                            usr.category1Value = @"";
                        }
                        //                address2 = nil;
                        //                budget = nil;
                        //                cat1 = nil;
                        usr.cat1 = @"";
                        //                category1Name = State;
                        //                category1Value = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category2_name"]]) {
                            
                            usr.category2Name = [info objectForKey:@"category2_name"];
                        } else {
                            usr.category2Name = @"";
                        }
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category2_value"]]) {
                            
                            usr.category2Value = [info objectForKey:@"category2_value"];
                        } else {
                            usr.category2Value = @"";
                        }
                        
                        //                category2Name = City;
                        //                category2Value = nil;
                        //                category3Name = nil;
                        //                category3Value = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category3_name"]]) {
                            
                            usr.category3Name = [info objectForKey:@"category3_name"];
                        } else {
                            usr.category3Name = @"";
                        }
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category3_value"]]) {
                            
                            usr.category3Value = [info objectForKey:@"category3_value"];
                        } else {
                            usr.category3Value = @"";
                        }
                        //                category4Name = nil;
                        //                category4Value = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category4_name"]]) {
                            
                            usr.category4Name = [info objectForKey:@"category4_name"];
                        } else {
                            usr.category4Name = @"";
                        }
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category4_value"]]) {
                            
                            usr.category4Value = [info objectForKey:@"category4_value"];
                        } else {
                            usr.category4Value = @"";
                        }
                        //                category5Name = nil;
                        //                category5Value = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category5_name"]]) {
                            
                            usr.category5Name = [info objectForKey:@"category5_name"];
                        } else {
                            usr.category5Name = @"";
                        }
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category5_value"]]) {
                            
                            usr.category5Value = [info objectForKey:@"category5_value"];
                        } else {
                            usr.category5Value = @"";
                        }
                        //                category6Name = nil;
                        //                category6Value = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category6_name"]]) {
                            
                            usr.category6Name = [info objectForKey:@"category6_name"];
                        } else {
                            usr.category6Name = @"";
                        }
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"category6_value"]]) {
                            
                            usr.category6Value = [info objectForKey:@"category6_value"];
                        } else {
                            usr.category6Value = @"";
                        }
                        //                cell = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"cell"]]) {
                            
                            usr.cell = [info objectForKey:@"cell"];
                        } else {
                            usr.cell = @"";
                        }
                        //                chartRef = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"chart_ref"]]) {
                            
                            usr.chartRef = [info objectForKey:@"chart_ref"];
                        } else {
                            usr.chartRef = @"";
                        }
                        //                city = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"city"]]) {
                            
                            usr.city = [info objectForKey:@"city"];
                        } else {
                            usr.city = @"";
                        }
                        //                clientName = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"client_name"]]) {
                            
                            usr.clientName = [info objectForKey:@"client_name"];
                        } else {
                            usr.clientName = @"";
                        }
                        //                clientNumber = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"client_number"]]) {
                            
                            usr.clientNumber = [info objectForKey:@"client_number"];
                        } else {
                            usr.clientNumber = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[company objectForKey:@"name"]]) {
                            
                            usr.company = [company objectForKey:@"name"];
                        } else {
                            usr.company = @"";
                        }
                        //                company = "Certified Safe Driver";
                        //                contactName = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"contact_name"]]) {
                            
                            usr.contactName = [info objectForKey:@"contact_name"];
                        } else {
                            usr.contactName = @"";
                        }
                        //                correctiveLensRequired = yes;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"corrective_lense_required"]]) {
                            
                            if ([info objectForKey:@"corrective_lense_required"]) {
                                usr.correctiveLensRequired = @"true";
                            } else {
                                usr.correctiveLensRequired = @"false";
                            }
                        } else {
                            usr.correctiveLensRequired = @"false";
                        }
                        //                country = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"country"]]) {
                            
                            usr.country = [info objectForKey:@"country"];
                        } else {
                            usr.country = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"country"]]) {
                            
                            usr.country = [info objectForKey:@"country"];
                        } else {
                            usr.country = @"";
                        }
                        usr.creatorRecordId = nil;
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"current_user_identity"]]) {
                            
                            usr.currentUserIdent = [info objectForKey:@"current_user_identity"];
                        } else {
                            usr.currentUserIdent = @"";
                        }
                        //                currentUserIdent = nil;
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"customer_number"]]) {
                            
                            usr.customerNumber = [info objectForKey:@"customer_number"];
                        } else {
                            usr.customerNumber = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"customer_number"]]) {
                            
                            usr.customerNumber = [info objectForKey:@"customer_number"];
                        } else {
                            usr.customerNumber = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"driver_license_class"]]) {
                            
                            usr.driverLicenseClass = [info objectForKey:@"driver_license_class"];
                        }
                        //                customerNumber = nil;
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"dot_expiration_date"]]) {
                            
                            NSString *dateString = [info objectForKey:@"dot_expiration_date"];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            NSDate *dateFromString = [dateFormatter dateFromString:dateString];
                            
                            usr.dOTExpirationDate = dateFromString;
                        } else {
                            usr.dOTExpirationDate = nil;
                        }
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"driver_license_expire_date"]]) {
                            
                            NSString *dateString = [info objectForKey:@"driver_license_expire_date"];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            NSDate *dateFromString = [dateFormatter dateFromString:dateString];
                            
                            usr.driverLicenseExpirationDate = dateFromString;
                        } else {
                            usr.driverLicenseExpirationDate = nil;
                        }
                        
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"driver_license_number"]]) {
                            
                            usr.driverLicenseNumber = [info objectForKey:@"driver_license_number"];
                        } else {
                            usr.driverLicenseNumber = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"driver_license_state"]]) {
                            
                            usr.driverLicenseState = [info objectForKey:@"driver_license_state"];
                        } else {
                            usr.driverLicenseState = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[student objectForKey:@"email"]]) {
                            
                            usr.email = [student objectForKey:@"email"];
                        } else {
                            usr.email = @"";
                        }
                        
                        usr.itemType = userType;
                        
                        if ([HelperSharedManager isCheckNotNULL:[student objectForKey:@"middle_name"]]) {
                            
                            usr.middleName = [student objectForKey:@"middle_name"];
                        } else {
                            usr.middleName = @"";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[student objectForKey:@"password"]]) {
                            
                            usr.password = [student objectForKey:@"password"];
                        } else {
                            usr.password = @"123123";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[student objectForKey:@"is_student"]]) {
                            
                           
                            BOOL isStudent = [[student objectForKey:@"is_student"] boolValue];
                            
                            if (isStudent) {
                                usr.rcoObjectClass = @"student";
                                usr.rcoObjectType = @"student";
                                NSLog(@"Student");
                            } else {
                                usr.rcoObjectClass = @"instructor";
                                usr.rcoObjectType = @"instructor";
                                NSLog(@"Not Student");
                            }
                            
                            
//                            usr.password = [student objectForKey:@"password"];
                        } else {
//                            usr.password = @"123123";
                        }
                        
                        if ([HelperSharedManager isCheckNotNULL:[info objectForKey:@"user_group_name"]]) {
                            
                            usr.userGroupName = [info objectForKey:@"user_group_name"];
                        } else {
                            usr.userGroupName = @"";
                        }
                        
                        usr.userId = idObj;
                        
                        
                        NSLog(@"User Id %@",usr.userId);
                        
                        
//                        [aggUser save];
                        [aggUser createNewRecord:usr];
                        
                    } else {
                        NSLog(@"User Already Exists");
                    }
                    
                    
                    
                    
                    
                }
                
            }
//            return  nil;
        });
    });
    
}

- (void)getCompanies {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *token = [Settings getSetting:USER_ACCESS_TOKEN];
    
    [[ServerManager sharedManager] getCompanies:token success:^(id responseObject) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self getInstructors];
            });
        });
        
        NSDictionary *resp = responseObject;
        if ([HelperSharedManager isCheckNotNULL:resp]) {
            
            NSArray *companies = [resp valueForKey:@"results"];
            if ([HelperSharedManager isCheckNotNULL:companies]) {
                
                NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                
                
                NSArray *sortedCompanies = [NSMutableArray arrayWithArray:[companies sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
                
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    for( NSDictionary * companyDict in sortedCompanies) {
                        
                        [self createNewCompany:companyDict];
                        
                    }
                });
                
                
                
                
            }
        }
        
        
        
    } failure:^(NSString *failureReason, NSInteger statusCode) {
        
        NSLog(@"Failure %@", failureReason);
    }];
}

- (void)createNewCompany: (NSDictionary *) dict {
    
    
    
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    
    TrainingCompanyAggregate *trAgg = (TrainingCompanyAggregate*)[[DataRepository sharedInstance] getAggregateForClass:@"TrainingCompany"];
    
    
    NSString *companyName = [dict valueForKey:@"name"];
    NSString *companyId = [dict valueForKey:@"id"];
    
    NSString *idObj =[NSString stringWithFormat:@"%@", companyId];
    
    if ([HelperSharedManager isCheckNotNULL:companyName]) {
        
        
        TrainingCompany *comp = [trAgg getTrainingCompanyWithName:companyName];
        
        if (!comp) {
            TrainingCompany *company = (TrainingCompany*)[agg createNewObject];
            company.name = companyName;
            company.companyId = idObj;
            company.dateTime = [NSDate date];
            
            NSLog(@"Company Does not exists %@", companyName);
            [agg save];
            
            [agg createNewRecord:company];
            
        } else {
            NSLog(@"Company Exists");
        }
        
        
        
        
    }
    
}

-(void)_goBack {
    
    NSNumber *popToRoot = self.homeTappingOption;
    
    BillingAppDelegate *app = (BillingAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    UIViewController *rootViewController = app.window.rootViewController;
    
    if ([rootViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitViewController = (UISplitViewController*)rootViewController;
        for (UINavigationController *navController in splitViewController.viewControllers) {
            UIViewController *baseVC = [navController.viewControllers objectAtIndex:0];
            
            if ([[baseVC class] isSubclassOfClass:[RCODataViewController class]]) {
                RCODataViewController *controller = (RCODataViewController *)navController.topViewController;

                if ([controller isKindOfClass:[RCODataViewController class]]) {
                    controller.fieldEditingDelegate = nil;
                    [[controller aggregate] unRegisterDetailForCallback: controller];
                    [[controller aggregate] unRegisterForCallback: controller];
                }
            }
        }
    }
    
    [Settings save];

    [UIView transitionWithView:self.navigationController.view.window
                      duration:/*0.3*/0
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        if ([popToRoot boolValue] || !app.baseViewController) {
                            app.window.rootViewController = self.rootViewController;
                        } else {
                            app.window.rootViewController = app.baseViewController;
                        }
                    }
                    completion:^(BOOL finished) {
                        [self reloadMenuItems:nil];
                    }];
    
    if (DEVICE_IS_IPHONE) {
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:nil afterDelay:0.0];
    }
}

-(void)homeTapped:(NSNotification*)notification {
    
    self.homeTappingOption = notification.object;

        [self _goBack];
}

- (void)loadMenuItems {
    
    

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            [self configureMainScreenForiPhone:NO orientation:YES];
        } else {
            [self configureMainScreenForiPhone:NO orientation:NO];
        }
    } else {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            [self configureMainScreenForiPhone:YES orientation:YES];
        } else {
            [self configureMainScreenForiPhone:YES orientation:NO];
        }
    }
    
    [self loadTheme];
    [self selectCurrentPage];
}

- (void)loadTheme {
}

-(NSString*)setCommandTitle:(NSString*)title {
    
    NSString *str = NSLocalizedString(title, nil);
    return [str uppercaseString];
}

-(NSArray*)getCSDApsItems:(BOOL)isAccident forDevice:(BOOL)isIphone {
    NSArray *userRights = [DataRepository sharedInstance].userRights;
    NSMutableArray *menuItems = [NSMutableArray array];

    if (isAccident) {
        if ([userRights containsObject:kTrainingAccident]) {
            if (isIphone) {
                [menuItems addObject:@"ACCIDENT"];
            } else {
                [menuItems addObject:@"ACCIDENT_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDAccidentFormIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"ACCIDENT", nil)];
        }
    } else {
        if ([userRights containsObject:kTrainingClassC]) {
            if (isIphone) {
                [menuItems addObject:@"WHEEL"];
            } else {
                [menuItems addObject:@"WHEEL_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDClassCFormIndex]];
           //[_menuItemsNames addObject:NSLocalizedString(@"CLASS C", nil)];
            [_menuItemsNames addObject:NSLocalizedString(@"BEHIND WHEEL", nil)];

        }
        if ([userRights containsObject:kTrainingPreTrip]) {
            if (isIphone) {
                [menuItems addObject:@"PRETRIP"];
            } else {
                [menuItems addObject:@"PRETRIP_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDPreTripFormIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"PRE TRIP", nil)];
        }
        
        if ([userRights containsObject:kTrainingBus]) {
            if (isIphone) {
                [menuItems addObject:@"BUS"];
            } else {
                [menuItems addObject:@"BUS_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDBusFormIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"BUS EVAL", nil)];
        }
        if ([userRights containsObject:kTrainingEyeMovements]) {
            if (isIphone) {
                [menuItems addObject:@"EYE"];
            } else {
                [menuItems addObject:@"EYE_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDEyeIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"EYE MOVEMENTS", nil)];
        }
        
        if ([userRights containsObject:kTrainingStudentsRight] ) {
            if (isIphone) {
                [menuItems addObject:@"STUDENTS"];
            } else {
                [menuItems addObject:@"STUDENTS_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDTrainingStudentsIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"STUDENTS", nil)];
        }
        
        if ([userRights containsObject:kTrainingInstructorsRight]) {
            if (isIphone) {
                [menuItems addObject:@"INSTRUCTORS"];
            } else {
                [menuItems addObject:@"INSTRUCTORS_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDTrainingInstructorsIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"INSTRUCTORS", nil)];
        }
        
        if ([userRights containsObject:kTrainingRight]) {
            if (isIphone) {
                [menuItems addObject:@"COMPANYTRAINING"];
            } else {
                [menuItems addObject:@"COMPANYTRAINING_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDTrainingCompanyIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"COMPANIES", nil)];
        }

    }
    
    if (![self isWaterApp]) {
        if ([userRights containsObject:kDisplayUsersRight]) {
            if (isIphone) {
                [menuItems addObject:@"USERS"];
            } else {
                [menuItems addObject:@"USERS_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kUsersIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"USERS", nil)];
        }
        
        if ([userRights containsObject:kDisplayUsersGroupsRight]) {
            if (isIphone) {
                [menuItems addObject:@"USERGROUPS"];
            } else {
                [menuItems addObject:@"USERGROUPS_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kUserGroupsIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"GROUPS", nil)];
        }
    }
    

    if ([userRights containsObject:@"Mobile-DisplaySyncStatus"] ) {
        if (isIphone) {
            [menuItems addObject:@"SYNCSTATUS_glass"];
        } else {
            [menuItems addObject:@"SYNCSTATUS_glass_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kSyncIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"SYNC STATUS", nil)];
    }
    
    if ([userRights containsObject:kSyncNowRight]) {
        if (isIphone) {
            [menuItems addObject:@"SYNCNOW"];
        } else {
            [menuItems addObject:@"SYNCNOW_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kSyncNowIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"SYNC NOW", nil)];
    }

    return menuItems;
}

- (NSArray*)loadRightsOld:(BOOL)isIphone {
    NSMutableArray *menuItems = [NSMutableArray array];
    
    if ([_menuItemsTags count] == 0) {
        _menuItemsTags = [NSMutableArray new];
    } else {
        [_menuItemsTags removeAllObjects];
    }
    
    if ([_menuItemsNames count] == 0) {
        _menuItemsNames = [NSMutableArray new];
    } else {
        [_menuItemsNames removeAllObjects];
    }
    
    NSArray *userRights = [DataRepository sharedInstance].userRights;
    
    BOOL  loadAll = NO;
    
#ifdef DEBUG
    loadAll = YES;
    for( NSString *theRight in userRights )
    {
        if( [theRight hasPrefix:@"Mobile-"] )
        {
            loadAll = NO;
            break;
        }
    }
#endif
    
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    BOOL isCSD = NO;
    BOOL isCSDAccidentForm = NO;
    
    if ([targetName isEqualToString:@"CSD"]) {
        isCSD = YES;
    } else if ([targetName isEqualToString:@"Accident Form"]) {
        isCSDAccidentForm = YES;
    }

    if (isCSD || isCSDAccidentForm) {
        return [self getCSDApsItems:isCSDAccidentForm forDevice:isIphone];
    }
    
    
    if (![self isWaterApp]) {
        if ([userRights containsObject:kDisplayUsersRight]) {
            if (isIphone) {
                [menuItems addObject:@"USERS"];
            } else {
                [menuItems addObject:@"USERS_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kUsersIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"USERS", nil)];
        }
        
        if ([userRights containsObject:kDisplayUsersGroupsRight]) {
            if (isIphone) {
                [menuItems addObject:@"USERGROUPS"];
            } else {
                [menuItems addObject:@"USERGROUPS_iPad"];
            }
            [_menuItemsTags addObject:[NSNumber numberWithInt:kUserGroupsIndex]];
            [_menuItemsNames addObject:NSLocalizedString(@"GROUPS", nil)];
        }
    }
    

    
    if ([userRights containsObject:kTrainingClassC] || loadAll) {
        if (isIphone) {
            [menuItems addObject:@"WHEEL"];
        } else {
            [menuItems addObject:@"WHEEL_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDClassCFormIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"BEHIND WHEEL", nil)];
    }

    if ([userRights containsObject:kTrainingPreTrip]) {
        if (isIphone) {
            [menuItems addObject:@"PRETRIP"];
        } else {
            [menuItems addObject:@"PRETRIP_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDPreTripFormIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"PRE TRIP", nil)];
    }

    if ([userRights containsObject:kTrainingBus]) {
        if (isIphone) {
            [menuItems addObject:@"BUS"];
        } else {
            [menuItems addObject:@"BUS_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDBusFormIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"BUS EVAL", nil)];
    }

    if ([userRights containsObject:kTrainingAccident] || loadAll) {
        if (isIphone) {
            [menuItems addObject:@"ACCIDENT"];
        } else {
            [menuItems addObject:@"ACCIDENT_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDAccidentFormIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"ACCIDENT", nil)];
    }

    if ([userRights containsObject:kTrainingEyeMovements] || loadAll) {
        if (isIphone) {
            [menuItems addObject:@"EYE"];
        } else {
            [menuItems addObject:@"EYE_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDEyeIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"EYE MOVEMENTS", nil)];
    }
    
    if ([userRights containsObject:kTrainingStudentsRight] || loadAll) {
        if (isIphone) {
            [menuItems addObject:@"STUDENTS"];
        } else {
            [menuItems addObject:@"STUDENTS_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDTrainingStudentsIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"STUDENTS", nil)];
    }

    if ([userRights containsObject:kTrainingInstructorsRight] || loadAll) {
        if (isIphone) {
            [menuItems addObject:@"INSTRUCTORS"];
        } else {
            [menuItems addObject:@"INSTRUCTORS_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kCSDTrainingInstructorsIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"INSTRUCTORS", nil)];
    }
    



    if ([userRights containsObject:@"Mobile-DisplaySyncStatus"] || loadAll) {
        if (isIphone) {
            [menuItems addObject:@"SYNCSTATUS_glass"];
        } else {
            [menuItems addObject:@"SYNCSTATUS_glass_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kSyncIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"SYNC STATUS", nil)];
    }

    if ([userRights containsObject:kSyncNowRight] || loadAll) {
        if (isIphone) {
            [menuItems addObject:@"SYNCNOW"];
        } else {
            [menuItems addObject:@"SYNCNOW_iPad"];
        }
        [_menuItemsTags addObject:[NSNumber numberWithInt:kSyncNowIndex]];
        [_menuItemsNames addObject:NSLocalizedString(@"SYNC NOW", nil)];
    }
    
    return menuItems;
}

- (NSArray*)loadRights:(BOOL)isIphone {
    
    NSString *orgNumber = [Settings getSetting:CLIENT_ORGANIZATION_ID];
    NSString *filename = nil;
    BOOL sortCommands = YES;
        filename = @"Commands.plist";
    
    NSString *commandsFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:@""];

    NSDictionary *commands = [NSDictionary dictionaryWithContentsOfFile:commandsFilePath];
    NSArray *commandsList = nil;
    commandsList = [commands.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray *menuItems = [NSMutableArray array];
    
    if ([_menuItemsTags count] == 0) {
        _menuItemsTags = [NSMutableArray new];
    } else {
        [_menuItemsTags removeAllObjects];
    }
    
    if ([_menuItemsNames count] == 0) {
        _menuItemsNames = [NSMutableArray new];
    } else {
        [_menuItemsNames removeAllObjects];
    }
    
    NSArray *userRights = [DataRepository sharedInstance].userRights;
    
    BOOL  loadAll = NO;
    
#ifdef DEBUG
    loadAll = YES;
    for( NSString *theRight in userRights )
    {
        if( [theRight hasPrefix:@"Mobile-"] )
        {
            loadAll = NO;
            break;
        }
    }
#endif
    
    for (NSString *commandKey in commandsList) {
        NSDictionary *commandinfo = [commands objectForKey:commandKey];
        NSString *cmdimage = [commandinfo objectForKey:@"image"];
        NSString *cmdRight = [commandinfo objectForKey:@"right"];
        NSNumber *cmdIndex = [commandinfo objectForKey:@"tag"];
        NSString *command = nil;
        if ([commandKey containsString:@"_"]) {
            NSArray *comp = [commandKey componentsSeparatedByString:@"_"];
            command = [comp objectAtIndex:1];
        } else {
            command = commandKey;
        }
        
        if ([userRights containsObject:cmdRight]) {
            [menuItems addObject:cmdimage];
            [_menuItemsTags addObject:cmdIndex];
            [_menuItemsNames addObject:NSLocalizedString(command, nil)];
        }
    }
    
    return menuItems;
}

-(CGSize)getScreenSizeForOrientation:(UIInterfaceOrientation)orientation{
    BOOL isPortrait = NO;
    
    if ((orientation == UIInterfaceOrientationLandscapeRight) ||
        (orientation == UIInterfaceOrientationLandscapeLeft)) {
        isPortrait = NO;
    } else {
        isPortrait = YES;
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGSize size = CGSizeZero;
    
    if (isPortrait) {
        // we should return the smaller dimension
        if (screenSize.width > screenSize.height) {
            size.height = screenSize.width;
            size.width = screenSize.height;
        } else {
            size.height = screenSize.height;
            size.width = screenSize.width;
        }
    } else {
        if (screenSize.width > screenSize.height) {
            size.height = screenSize.height;
            size.width = screenSize.width;
        } else {
            size.height = screenSize.width;
            size.width = screenSize.height;
        }
    }
    return size;
}


- (NSDictionary*)getNumberOfItemsiPhone:(BOOL)isPhone orientation:(BOOL)isPortrait {
    
    NSInteger rowNrItems = 0;
    NSInteger colNrItems = 0;
    
    NSInteger  X = 10;
    NSInteger Y = 40;
    
    double width = 100.0;
    double height = 100.0;
    
    CGSize screenSize = CGSizeZero;
    
    if (isPortrait) {
        screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationPortrait];
    } else {
        screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationLandscapeLeft];
    }
    
    if (isPhone) {
        // iPhone configurations
        if (isPortrait) {
            rowNrItems = 3;
            colNrItems = 3;
            
            X = 10;
            Y = 40;
        } else {
            rowNrItems = 2;
            colNrItems = 3;
            
            X = 30;
            Y = 20;
        }
    } else {
        // iPad configurations
        width = 225;
        height = 225;
        
        if (isPortrait) {
            rowNrItems = 3;
            colNrItems = 3;
            
            X = 10;
            Y = 40;
        } else {
            rowNrItems = 3;
            colNrItems = 3;
            
            X = 30;
            Y = 30;
        }
    }

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:[NSNumber numberWithInteger:rowNrItems] forKey:kNumberOfRows];
    [result setObject:[NSNumber numberWithInteger:colNrItems] forKey:kNumberOfColumns];
    [result setObject:[NSNumber numberWithDouble:width] forKey:kIconWidth];
    [result setObject:[NSNumber numberWithDouble:height] forKey:kIconHeight];
    [result setObject:[NSNumber numberWithInteger:X] forKey:kStartX];
    [result setObject:[NSNumber numberWithInteger:Y] forKey:kStartY];

    return result;
}

- (void)configureMainScreenForiPhone:(BOOL)isPhone orientation:(BOOL)isPortrait{
    
    
    
    if ([_menuItems count] == 0) {
        _menuItems = [NSMutableArray new];
        [_menuItems addObjectsFromArray:[self loadRights:isPhone]];
    }
    
    NSInteger nrItems = [_menuItems count];
    
    NSInteger rowNrItems = 0;
    NSInteger colNrItems = 0;
    
    double screenWidth = 0;
    double screenHeight = 0;
    
    NSInteger  X = 10;
    NSInteger Y = 40;
    
    double width = 100.0;
    double height = 100.0;
    
    CGSize screenSize = CGSizeZero;
    
    if (isPortrait) {
        screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationPortrait];
    } else {
        screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationLandscapeLeft];
    }
    
    NSDictionary *params = [self getNumberOfItemsiPhone:isPhone orientation:isPortrait];
    X = [[params objectForKey:kStartX] integerValue];
    Y = [[params objectForKey:kStartY] integerValue];
    rowNrItems = [[params objectForKey:kNumberOfRows] integerValue];
    colNrItems = [[params objectForKey:kNumberOfColumns] integerValue];
    width = [[params objectForKey:kIconWidth] doubleValue];
    height = [[params objectForKey:kIconHeight] doubleValue];
    
    NSInteger nrOfpages = nrItems / (rowNrItems * colNrItems);
    
    if (nrOfpages == 0) {
        nrOfpages = 1;
    } else {
        if (nrItems % (rowNrItems * colNrItems)) {
            nrOfpages += 1;
        }
    }
    
    UIScrollView *scroll = nil;
    
    if (_currentPage == PageNotSet) {
        _currentPage = 0;
    }
    if (_currentPage >= nrOfpages) {
        
        _currentPage = nrOfpages - 1;
        if (_currentPage < 0) {
            _currentPage = 0;
        }
    }
    
    double statusBarHeight = 0;
    
    static BOOL hasPortraitFrameChanged = NO;
    
    scroll = self.portraitScroll;
    self.portraitControl.numberOfPages = nrOfpages;
    self.portraitControl.currentPage = _currentPage;
    CGRect frame = self.portraitControl.frame;
    if (!hasPortraitFrameChanged) {
        hasPortraitFrameChanged = YES;
    }
    self.portraitControl.frame = frame;

    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.scrollsToTop = NO;

    screenHeight = scroll.frame.size.height;
    screenWidth = scroll.frame.size.width;

    scroll.contentSize = CGSizeMake(screenWidth*nrOfpages, screenHeight);

    [scroll setBackgroundColor:[UIColor clearColor]];

    double deltaX = (screenWidth - colNrItems*width - 2*X )/ (colNrItems*1.0 - 1);
    double deltaY = (screenHeight  - rowNrItems*height - 2*Y)/ (rowNrItems*1.0 - 1);
    
    double x = 0;
    double y = 0;
    
    statusBarHeight = 0;
    
    int btnIndex = 0;
    
    NSString *organizationId = [[DataRepository sharedInstance] orgNumber];

    for (int j = 0; j < nrOfpages; j++) {
        
        x = j*screenWidth + X;
        y = Y;
        
        CGRect frame = CGRectMake(x - X, 0 + statusBarHeight, screenWidth, screenHeight);
        
        for (int i = 0; i < rowNrItems; i++) {
            
            for (int k = 0; k < colNrItems; k++) {
                //UIButton *btn = nil;
                UIButton *btn = nil;

                if (btnIndex < nrItems) {
                    NSInteger btnTag = [[_menuItemsTags objectAtIndex:btnIndex] intValue];
                    NSString *btnTitle = [_menuItemsNames objectAtIndex:btnIndex];
                    
                    btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    
                     
                    [btn.titleLabel setNumberOfLines:2];
                    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
                    [btn setTitle:btnTitle forState:UIControlStateNormal];
                    
                    NSString *imageName = [_menuItems objectAtIndex:btnIndex];
                    UIImage *commandImage = nil;
                    if (DEVICE_IS_IPAD) {
                        NSString *ipadImageName = [NSString stringWithFormat:@"%@_iPad", imageName];
                        commandImage = [UIImage imageNamed:ipadImageName];
                        if (!commandImage) {
                            // we have the same image for iPhone & iPad
                            commandImage = [UIImage imageNamed:imageName];
                        } else {
                            imageName = ipadImageName;
                        }
                    } else {
                        commandImage = [UIImage imageNamed:imageName];
                    }
                    
                    [btn setBackgroundImage:commandImage forState:UIControlStateNormal];
                    [btn addTarget:self
                            action:@selector(itemTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
                    btn.tag = btnTag;
                    
                    if (btnTag == kSyncIndex) {
                        BOOL showFileUploadingLabel = NO;

                        double cp_width = [UIImage imageNamed:imageName].size.width*2/3;
                        double cp_offset = [UIImage imageNamed:imageName].size.width/8;
                        
                        DACircularProgressView *cp = [[DACircularProgressView alloc] initWithFrame: CGRectMake(x +(width-cp_width)/2,
                                                                                                               y + cp_offset,
                                                                                                               cp_width,
                                                                                                               cp_width)];
                        
                        cp.trackTintColor = [UIColor clearColor];
                        cp.trackTintColor = [UIColor lightGrayColor];

                        cp.progressTintColor = [UIColor yellowColor];
                        cp.thicknessRatio = 1.0f;
                        
                        CGRect frame;
                        
                        double labelHeight = 40;
                        
                        if (DEVICE_IS_IPHONE) {
                            labelHeight = 30;
                        }
                        
                        if (!showFileUploadingLabel) {
                            labelHeight *= 2;
                        }
                        
                        if (DEVICE_IS_IPHONE) {
                            frame = CGRectMake(x +(width-cp_width)/2,
                                               y + cp_width/3 - 5,
                                               cp_width,
                                               labelHeight);
                        } else {
                            frame = CGRectMake(x +(width-cp_width)/2,
                                               y + cp_width/3,
                                               cp_width,
                                               labelHeight);
                        }
                        
                        UILabel *recordLabel = [[UILabel alloc] initWithFrame:frame];
                        recordLabel.textAlignment = NSTextAlignmentCenter;
                        recordLabel.backgroundColor = [UIColor clearColor];
                        recordLabel.shadowColor = [UIColor grayColor];
                        recordLabel.adjustsFontSizeToFitWidth = TRUE;
                        recordLabel.tag = kSyncProgressRecordLabel;
                        recordLabel.numberOfLines = 2;
                        recordLabel.textColor = [UIColor darkTextColor];
                        
                        if (self.lastProgressStatus) {
                            recordLabel.text = self.lastProgressStatus;
                        }
                        
                        if (DEVICE_IS_IPHONE) {
                            recordLabel.font = [UIFont systemFontOfSize:10];
                        }
                        
                        UILabel *fileLabel = nil;
                        
                        if (showFileUploadingLabel) {
                            
                            if (DEVICE_IS_IPHONE) {
                                frame = CGRectMake(x +(width-cp_width)/2,
                                                   y + cp_width/3 + 20,
                                                   cp_width, 30);
                            } else {
                                frame = CGRectMake(x +(width-cp_width)/2,
                                                   y + cp_width/3 + 60,
                                                   cp_width, 40);
                            }

                            fileLabel = [[UILabel alloc] initWithFrame:frame];
                            fileLabel.textAlignment = NSTextAlignmentCenter;
                            fileLabel.backgroundColor = [UIColor clearColor];
                            fileLabel.shadowColor  = [UIColor grayColor];
                            fileLabel.adjustsFontSizeToFitWidth=TRUE;
                            fileLabel.numberOfLines=2;
                            if (DEVICE_IS_IPHONE) {
                                fileLabel.font = [UIFont systemFontOfSize:10];
                            }
                        }
                        
                        self.cpPortrait = cp;
                        self.recordLabelPortrait = recordLabel;
                        self.fileLabelPortrait = fileLabel;
                        
                        [scroll addSubview:cp];
                        [scroll addSubview:recordLabel];
                        [scroll addSubview:fileLabel];
                    }
                } else{
                    break;
                }
                
                btn.frame = CGRectMake(x, y, width, height);
                
                // we need to calculate the insets differently and also the font for iPad and iPhone
                if (DEVICE_IS_IPAD) {
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(height - 30, 0, 10, 0)];
                } else {
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(height - 10, 0, 5, 0)];
                }
                
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                if (DEVICE_IS_IPAD) {
                    [btn.titleLabel setFont:[UIFont systemFontOfSize:20]];
                } else {
                    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
                    [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
                }

                //btn.tag = btnIndex;
                btnIndex++;
                
                [scroll addSubview:btn];
                x += deltaX + width;
            }
            
            y += height + deltaY;
            x = j*screenWidth + X;
        }
    }
    
    
    
    
}

- (void)doRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (!self.isVisible) {
        NSLog(@"");
        return;
    }
    
    [self reloadMenuItems:nil];
    [self scrollToCurrentPage:toInterfaceOrientation];
}

-(void)scrollToCurrentPage:(UIInterfaceOrientation)orientation {
    float screenWidth = 0;
    CGPoint offsetPortrait ;
    CGPoint offsetLandscape ;
    
    CGSize screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationPortrait];

    screenWidth = self.portraitScroll.frame.size.width;

    offsetPortrait = CGPointMake(_currentPage*screenWidth, 0);
    
    screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationLandscapeLeft];
    
    screenWidth = screenSize.width;
    offsetLandscape = CGPointMake(_currentPage*screenWidth, 0);
    
    [self.portraitScroll setContentOffset:offsetPortrait animated:NO];
}

-(void)scrollBackgroundPages{
    float screenWidth = 0;
    CGPoint offsetPortrait ;
    CGPoint offsetLandscape ;
    
    CGSize screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationPortrait];

    screenWidth = screenSize.width;

    offsetPortrait = CGPointMake(_currentPage*screenWidth, 0);
    
    screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationLandscapeLeft];
    
    screenWidth = screenSize.width;

    offsetLandscape = CGPointMake(_currentPage*screenWidth, 0);
}

- (void) launchChildController: (UIViewController*) controller
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarColor]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(goHome)];
    controller.navigationItem.leftBarButtonItem = homeButton;
    //FIX [self presentModalViewControlleriOS6:navController animated:YES];
    //02.10.2019 should we have full screnn or sheet style?
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
    
    
    
    
    
    
    
}

- (void) goHome {
    [self dismissModalViewControllerAnimatediOS6:YES];
}

-(void)selectCommandWithId:(NSNumber*)commandNumber {
    NSInteger index = [commandNumber integerValue];
        
    NSInteger i = 0;
    for (i = 0; i < _menuItems.count; i++) {
        NSInteger btnTag = [[_menuItemsTags objectAtIndex:i] integerValue];
        
        if (index == btnTag) {
            // we found the previous command
            NSInteger currentPage = [self getScrollingIndexForCommandIndex:i];
            UIButton *commandButton = nil;
            
            self.portraitControl.currentPage = currentPage;
            commandButton = (UIButton*)[self.portraitScroll viewWithTag:btnTag];
            [self changePage:self.portraitControl];
            
            
            
            if (commandButton) {
                [self performSelector:@selector(itemTapped:)
                           withObject:commandButton
                           afterDelay:1];
                
            }
            break;
        }
    }
}

-(void)selectCurrentPage {
}

-(NSInteger)getScrollingIndexForCommandIndex:(NSInteger)commandIndex {
    
    if (commandIndex == 0) {
        return 0;
    }
    NSDictionary *params = [self getNumberOfItemsiPhone:DEVICE_IS_IPHONE
                                            orientation:UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)];
    
    NSInteger rows = [[params objectForKey:kNumberOfRows] integerValue];
    NSInteger colums = [[params objectForKey:kNumberOfColumns] integerValue];
    NSInteger itemsPerPage = rows*colums;
    
    if (itemsPerPage == 0) {
        return 0;
    }
    
    return commandIndex/itemsPerPage;
}

#pragma mark -
#pragma mark Actions

-(void)saveSettings {
    
    [Settings save];
}

-(void)itemTapped:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    
    
    
    
    switch (btn.tag) {
            
        case kUsersIndex:
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"Users"];
            
            
                
            [self performSelector:@selector(loadUsers) withObject:nil afterDelay:0.1];
        }

        case kCSDClassCFormIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"Behind wheel"];
            
            [self performSelector:@selector(loadCSDForm:) withObject:@"01" afterDelay:0.1];
#endif
        }
            break;

        case kCSDPreTripFormIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"Pre Trip"];
            
            [self performSelector:@selector(loadCSDForm:) withObject:@"02" afterDelay:0.1];
#endif
        }
            break;
        case kCSDBusFormIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"Bus"];
            
            [self performSelector:@selector(loadCSDForm:) withObject:@"03" afterDelay:0.1];
#endif
        }
            break;

        case kCSDAccidentFormIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"Accident"];
            
            [self performSelector:@selector(loadCSDAccidents) withObject:nil afterDelay:0.1];
#endif
        }
            break;

        case kCSDEyeIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"Eye Movements"];
            
            [self performSelector:@selector(loadCSDEye) withObject:nil afterDelay:0.1];
#endif
        }
            break;
        case kCSDTestIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"Test"];
                        
            [self performSelector:@selector(loadCSDInfo) withObject:nil afterDelay:0.1];
#endif
        }
            break;

        case kCSDTrainingStudentsIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"STUDENTS"];
            
            [self performSelector:@selector(loadStudents) withObject:nil afterDelay:0.1];
#endif
        }
            break;
            
        case kCSDTrainingInstructorsIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"INSTRUCTORS"];
            
            [self performSelector:@selector(loadInstructors) withObject:nil afterDelay:0.1];
#endif
        }
            break;

        case kCSDTrainingCompanyIndex:
        {
#ifdef APP_CSD
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commandStartLoading" object:@"COMPANIES"];
            
            [self performSelector:@selector(loadCompanies) withObject:nil afterDelay:0.1];
#endif
        }
            break;

            
        default:
            break;
    }
}


- (IBAction)changePage:(UIPageControl*)control {
    
    double width = 0;
    CGPoint point;
    width = self.portraitScroll.frame.size.width;

     if (control == self.portraitControl) {
        point = CGPointMake(width * self.portraitControl.currentPage, 0);
        _currentPage = self.portraitControl.currentPage;
        [self.portraitScroll setContentOffset:point animated:YES];
    }
}


-(void)launchMaster:(UIViewController*)master andDetail:(UIViewController*)detail {
    
    self.homeTappingOption = nil;
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarColor]];
    
    UINavigationController *masterNav = [[UINavigationController alloc] initWithRootViewController:master];
    UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:detail];
    
    UISplitViewController* splitViewController = [[UISplitViewController alloc] init];
    splitViewController.delegate = self;
    splitViewController.viewControllers = @[masterNav, detailNav];
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    BillingAppDelegate *app = (BillingAppDelegate*) [[UIApplication sharedApplication] delegate];
    app.baseViewController = nil;
    
    UIViewController *currentController = self.rootViewController;
    
    app.window.rootViewController = currentController;
    
    [UIView transitionWithView:self.navigationController.view.window
                      duration:/*0.3*/0
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        app.window.rootViewController = splitViewController;
                    }
                    completion:nil];
}

#pragma mark -
#pragma mark UIScrollViewdDlegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint point = scrollView.contentOffset;
    double widthP = 0;
    double widthL = 0;
    
    CGSize screenSize = CGSizeZero;
    
    if (scrollView == self.portraitScroll){
        screenSize = [self getScreenSizeForOrientation:UIInterfaceOrientationPortrait];

        widthP = screenSize.width;
        widthP = self.portraitScroll.frame.size.width;
        
        _currentPage = point.x / widthP;
        [self.portraitScroll setContentOffset:CGPointMake(_currentPage*widthP, 0)];
    }
    
    if (scrollView == self.portraitScroll) {
        [self.portraitScroll setContentOffset:CGPointMake(_currentPage*widthP, 0)];
    }
    
    self.portraitControl.currentPage = _currentPage;
    
}

#pragma mark Setters
- (void) setCpPortrait:(DACircularProgressView *)cpPortrait
{
    if( _cpPortrait ) {
        [[DataRepository sharedInstance].statusDict removeObserver:self.cpPortrait
                                                        forKeyPath:kSyncProgress
                                                           context:nil];
        DACircularProgressView *t = _cpPortrait;
        _cpPortrait=nil;
    }
    
    if( cpPortrait ) {
        _cpPortrait = cpPortrait;
        
        [[DataRepository sharedInstance].statusDict addObserver:self.cpPortrait
                                                     forKeyPath:kSyncProgress
                                                        options:NSKeyValueObservingOptionNew
                                                        context:nil];
    }
   
}
- (void) setCpLandscape:(DACircularProgressView *)cpLandscape
{
    if( self.cpLandscape ) {
        [[DataRepository sharedInstance].statusDict removeObserver:self.cpLandscape
                                                        forKeyPath:kSyncProgress
                                                           context:nil];
        DACircularProgressView *t = self.cpLandscape;
        _cpLandscape=nil;
    }
    
    if( cpLandscape ) {
        _cpLandscape = cpLandscape;
        
        [[DataRepository sharedInstance].statusDict addObserver:self.cpLandscape
                                                     forKeyPath:kSyncProgress
                                                        options:NSKeyValueObservingOptionNew
                                                        context:nil];
    }
    
}

- (void) setRecordLabelPortrait:(UILabel *)recordLabelPortrait
{
    if( self.recordLabelPortrait ) {
        
        for (NSString *key in [NSArray arrayWithObjects:kObjectsSynced, kObjectsToSync, kSyncNetworkStatus, nil] ) {
            [[DataRepository sharedInstance].statusDict removeObserver:self.recordLabelPortrait
                                                            forKeyPath:key
                                                               context:nil];
        }

        UILabel *t = self.recordLabelPortrait;
        _recordLabelPortrait=nil;
    }
    
    if( recordLabelPortrait ) {
        recordLabelPortrait.tag = 1;
        _recordLabelPortrait = recordLabelPortrait;
        
        for (NSString *key in [NSArray arrayWithObjects:kObjectsSynced, kObjectsToSync,kSyncNetworkStatus, nil] ) {
            [[DataRepository sharedInstance].statusDict addObserver:self.recordLabelPortrait
                                                         forKeyPath:key
                                                            options:NSKeyValueObservingOptionNew
                                                            context:nil];
        }
    }
}

- (void) setRecordLabelLandscape:(UILabel *)recordLabelLandscape
{
    if( self.recordLabelLandscape ) {
        
        for (NSString *key in [NSArray arrayWithObjects:kObjectsSynced, kObjectsToSync, kSyncNetworkStatus, nil] ) {
            [[DataRepository sharedInstance].statusDict removeObserver:self.recordLabelLandscape
                                                            forKeyPath:key
                                                               context:nil];
        }
        
        UILabel *t = self.recordLabelLandscape;
        _recordLabelLandscape=nil;
    }
    
    if( recordLabelLandscape ) {
        _recordLabelLandscape = recordLabelLandscape;
        recordLabelLandscape.tag = 1;
        
        for (NSString *key in [NSArray arrayWithObjects:kObjectsSynced, kObjectsToSync, kSyncNetworkStatus, nil] ) {
            [[DataRepository sharedInstance].statusDict addObserver:self.recordLabelLandscape
                                                         forKeyPath:key
                                                            options:NSKeyValueObservingOptionNew
                                                            context:nil];
        }
    }
}

- (void) setFileLabelPortrait:(UILabel *)fileLabelPortrait
{
    if( self.fileLabelPortrait ) {
        
        for (NSString *key in [NSArray arrayWithObjects:kFilesSynced, kFilesToSync, kSyncNetworkStatus, nil] ) {
            [[DataRepository sharedInstance].statusDict removeObserver:self.fileLabelPortrait
                                                            forKeyPath:key
                                                               context:nil];
        }
        
        UILabel *t = self.fileLabelPortrait;
        _fileLabelPortrait=nil;
    }
    
    if( fileLabelPortrait ) {
        _fileLabelPortrait = fileLabelPortrait;
        
        for (NSString *key in [NSArray arrayWithObjects:kFilesSynced, kFilesToSync, kSyncNetworkStatus, nil] ) {
            [[DataRepository sharedInstance].statusDict addObserver:self.fileLabelPortrait
                                                         forKeyPath:key
                                                            options:NSKeyValueObservingOptionNew
                                                            context:nil];
        }
    }
}

- (void) setFileLabelLandscape:(UILabel *)fileLabelLandscape
{
    if( self.fileLabelLandscape ) {
        
        for (NSString *key in [NSArray arrayWithObjects:kFilesSynced, kFilesToSync, kSyncNetworkStatus, nil] ) {
            [[DataRepository sharedInstance].statusDict removeObserver:self.fileLabelLandscape
                                                            forKeyPath:key
                                                               context:nil];
        }
        
        UILabel *t = self.fileLabelLandscape;
        _fileLabelLandscape=nil;
    }
    
    if( fileLabelLandscape ) {
        _fileLabelLandscape = fileLabelLandscape;
        
        for (NSString *key in [NSArray arrayWithObjects:kFilesSynced, kFilesToSync, kSyncNetworkStatus, nil] ) {
            [[DataRepository sharedInstance].statusDict addObserver:self.fileLabelLandscape
                                                         forKeyPath:key
                                                            options:NSKeyValueObservingOptionNew
                                                            context:nil];
        }
    }
}

- (void)triggerTimer
{
}

- (void)startDispatcher
{
    @try
    {
        NSLog(@"Tick");
        if([LaunchMenuViewController sharedInstance].mTimer && [[LaunchMenuViewController sharedInstance].mTimer isValid]) {
            [[LaunchMenuViewController sharedInstance].mTimer invalidate];
            [LaunchMenuViewController sharedInstance].mTimer = nil;
        }
        [LaunchMenuViewController sharedInstance].mTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(triggerTimer) userInfo:nil repeats:YES];
    }
    @catch (NSException *exception)
    {
        [NSException raise:@"Exception" format:@"Exception in startDispatcher"];
    }
    @finally {
        
    }
}

#pragma mark Load Commands Methods

-(void)loadInventory {
}

-(void)loadTaxi {
}

-(void)loadPickup {
}

-(void)loadRack {
}


-(void)loadInstructors {
#ifdef APP_CSD
    UsersViewController *controller = [[UsersViewController alloc] initWithNibName:@"UsersViewController" bundle:nil];
    controller.userItemType = kUserTypeInstructor;
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
#endif
}

-(void)loadCompanies {
#ifdef APP_CSD
    CSDTrainingCompanyListViewController *controller = [[CSDTrainingCompanyListViewController alloc] initWithNibName:@"CSDTrainingCompanyListViewController" bundle:nil];
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
#endif
}

-(void)loadStudents {
#ifdef APP_CSD
    UsersViewController *controller = [[UsersViewController alloc] initWithNibName:@"UsersViewController" bundle:nil];
    controller.userItemType = kUserTypeStudent;
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
#endif
}


-(void)loadCSDForm:(NSString*)formIndexStr {
#ifdef APP_CSD
#ifndef APP_CSD_ACCIDENT
    CSDFormsListViewController *controller = [[CSDFormsListViewController alloc] initWithNibName:@"CSDFormsListViewController" bundle:nil];
    controller.formNumber = formIndexStr;
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
#endif
#endif
}

-(void)loadCSDAccidents {
#ifdef APP_CSD
    CSDAccidentFormsListViewController *controller = [[CSDAccidentFormsListViewController alloc] initWithNibName:@"CSDAccidentFormsListViewController" bundle:nil];
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
#endif
}

-(void)loadCSDEye {
#ifdef APP_CSD
    CSDEyeMovementViewController *controller = [[CSDEyeMovementViewController alloc] initWithNibName:@"CSDEyeMovementViewController" bundle:nil];
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
#endif
}


-(void)loadCSDInfo {
#ifdef APP_CSD
#ifndef APP_CSD_ACCIDENT
    CSDInfoViewController *controller = [[CSDInfoViewController alloc] initWithNibName:@"CSDInfoViewController" bundle:nil];
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverModalForViewController:controller];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewControlleriOS6:navController animated:YES];
    }
#endif
#endif
}




-(void)loadCSDScores {
#ifdef APP_CSD
#ifndef APP_CSD_ACCIDENT
    CSDScoresViewController *controller = [[CSDScoresViewController alloc] initWithNibName:@"CSDScoresViewController" bundle:nil];
    [self launchChildController: controller];
#endif
#endif
}


-(void)loadCSDDashboard {
#ifdef APP_CSD
#ifndef APP_CSD_ACCIDENT
    NSLog(@"");
    CSDDashboardViewController *controller = [[CSDDashboardViewController alloc] initWithNibName:@"CSDDashboardViewController2" bundle:nil];
    //CSDDashboardViewController *controller = [[CSDDashboardViewController alloc] initWithNibName:@"CSDDashboardViewController" bundle:nil];

    [self launchChildController: controller];
#endif
#endif
}



-(void)loadSales {
}

-(void)loadCompressorSlip {
}

-(void)loadTruckScale {
}

-(void)loadShipping {
}

-(void)loadShips {
}

-(void)loadTruck {
}

-(void)loadInvoices:(id)sender {
}


-(void)loadExpenses {
}

-(void)loadNewReceiving {
}

-(void)loadUserGroups {
    UserGroupsListViewController *controller = [[UserGroupsListViewController alloc] initWithNibName:@"UserGroupsListViewController" bundle:nil];
    [self launchChildController:controller];
}

-(void)loadUsers {
    UsersViewController *controller = [[UsersViewController alloc] initWithNibName:@"UsersViewController" bundle:nil];
    controller.showAddButton = YES;
    
    
    
    
    
    
    
    [self launchChildController:controller];
}

-(void)doLogout {
    NSLog(@"");
    [[DataRepository sharedInstance] setIsLoggedIn:NO];
    
    [[DataRepository sharedInstance] syncStop];
    
    [[DataRepository sharedInstance] resetStatus];
    
    [[DataRepository sharedInstance] resetAggregates];
    
    [[DataRepository sharedInstance] setSyncStatus:SYNC_STATUS_NONE];
    
    [self performSelector:@selector(showLogin:) withObject:nil afterDelay:0.3];
}

-(void)askLogout:(UIButton*)btn {
    
    self.logoutAlert = [[UIAlertView alloc] initWithTitle:@"Notificatin"
                                                  message:@"Do you want to Logout?"
                                                 delegate:self
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"Yes", @"Cancel", nil];
    self.logoutAlert.tag = TAG_LOGOUT;
    [self.logoutAlert show];
}


-(void)syncNow {
    // we should start a sync
    NSString *message = NSLocalizedString(@"Starting a full sync. Do you want to continue?", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Yes", nil), @"No", nil];
    alert.tag = TAG_FULL_SYNC;
    [alert show];
}

-(void)_syncNow {
    // reset the progress
    [self.cpLandscape setProgress:0];
    [self.cpPortrait setProgress:0];
    
    [[DataRepository sharedInstance] fullSyncStart];
}

-(void)loadSyncStatus {
}

-(void)loadTimecard {
}

-(void)loadCheckOut {
}

-(void)loadCheckIn {
}

#pragma mark -
#pragma mark iOS 6 Only

-(NSUInteger)supportedInterfaceOrientations
{
#ifdef UIInterfaceOrientationMaskAll
    return UIInterfaceOrientationMaskAll;
#else
    typedef enum {
        UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
        UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
        UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
        UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
        UIInterfaceOrientationMaskLandscape =
        (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
        UIInterfaceOrientationMaskAll =
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
        UIInterfaceOrientationMaskAllButUpsideDown =
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight),
    } UIInterfaceOrientationMask;
    
    return UIInterfaceOrientationMaskAll;
#endif
}

-(void)resetChangeFlag {
}


#pragma mark - 
#pragma mark UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation NS_AVAILABLE_IOS(5_0) {
    return NO;
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_LOGOUT) {
        if (buttonIndex == 0) {
            [self doLogout];
        }
    } else if (alertView.tag == TAG_FULL_SYNC) {
        if (buttonIndex == 0) {
            [self _syncNow];
        }
    }
}

-(Aggregate*)aggregate: (NSString *) type  {
    
    return [[DataRepository sharedInstance] getAggregateForClass:type];
}


//
//- (void)getUsersAndInstructors {
//
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//
//    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSavedAccessToken];
//
//    [[ServerManager sharedManager] getUsersAndInstructors:token success:^(id responseObject) {
//
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//        });
//
//        NSDictionary *resp = responseObject;
//        if ([HelperSharedManager isCheckNotNULL:resp]) {
//
//            NSArray *users = [resp valueForKey:@"results"];
//            if ([HelperSharedManager isCheckNotNULL:users]) {
//
//                NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES];
//
//
//                self.instructors = [NSMutableArray arrayWithArray:[users sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]]];
//
//
//
//
//            }
//        }
//
//
//
//    } failure:^(NSString *failureReason, NSInteger statusCode) {
//
//        NSLog(@"Failure %@", failureReason);
//    }];
//}
@end
