//
//  BillingAppDelegate.m
//  Billing
//
//  Created by Thomas Smallwood on 6/17/11.
//  Copyright 2011 RCO All rights reserved.
//

#import "BillingAppDelegate.h"
#import "DataRepository.h"
#import "LaunchMenuViewController.h"
#import "Settings.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <BRYXBanner/BRYXBanner-Swift.h>

#import "MobileOffice-Swift.h"

#define TAG_SYNC_MESSAGE 6666

#define Status_Background 1
#define Status_Active 2

@class Banner;
@class BannerPlus;

@interface BillingAppDelegate()
@property (nonatomic, strong) NSData *crashData;
@property (nonatomic, assign) NSInteger appStatus;
@property (nonatomic, strong) BannerPlus *banner;

@end

@implementation BillingAppDelegate

@synthesize window=_window;

@synthesize navController;

@synthesize currentButton, crashData;

#pragma mark - application lifecycle

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation NS_AVAILABLE_IOS(4_2) {
    return YES;
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
}

-(void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
}



-(NSString*)getGoogleServiceInfoFile {
    return [[NSBundle mainBundle] pathForResource:@"GoogleService-Info-CSD" ofType:@"plist"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
                                                       UIUserNotificationTypeAlert|
                                                       UIUserNotificationTypeBadge|
                                                       UIUserNotificationTypeSound categories:nil]];
    }
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
     [application setStatusBarStyle:UIStatusBarStyleLightContent];

    
    [self finishCrashLog];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLoading:) name:@"applicationStartLoading" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStart:) name:@"syncStart" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoading:) name:@"applicationLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLoading:) name:@"commandStartLoading" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoading:) name:@"commandLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLoadingMessage:) name:@"setLoadingMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startNetworkActivityIndicator:) name:@"startNetworkActivityIndicator" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopNetworkActivityIndicator:) name:@"stopNetworkActivityIndicator" object:nil];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[DataRepository sharedInstance] syncStop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.appStatus = Status_Background;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DataRepository *dr = [DataRepository sharedInstance];

    if (self.appStatus == Status_Active) {
        // this might be caused by receiving a permission
    } else {
        if( dr.isLoggedIn ) {
            [dr syncStart];
            self.appStatus = Status_Active;
        }
    }
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@">>>applicationWillTerminate");
    [[DataRepository sharedInstance] startUnloadingUserAggregates:nil returnMsg:nil];
    [Settings save];
}

- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationStartLoading" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncStart" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"commandStartLoading" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"commandLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setLoadingMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startNetworkActivityIndicator" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopNetworkActivityIndicator" object:nil];

    _crashData = nil;
    _progressHUD = nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
     */
}

#pragma mark - HUD
-(void)removeLoading:(NSNotification*)notification {
    
    if ([[notification name] isEqualToString:@"applicationLoaded"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectPreviousCommand" object:nil];
    }
    [_progressHUD hide:NO];
    _progressHUD = nil;
}

-(void)syncStart:(NSNotification*)notification {
    
    DataRepository *dr = [DataRepository sharedInstance];
    
    BOOL showAlertMessage = YES;
    
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        showAlertMessage = [notification.object boolValue];
    }
    
    BOOL hideSyncMessages = [dr hideSyncMessages];
    
    if ([[dr.syncOptions valueForKey:kDataSyncManuallyKey] boolValue] == NO) {
        if ([dr isNetworkReachable]) {
            // if is auto sync then we should show the message
            if (showAlertMessage && !hideSyncMessages) {
                [self showSyncAlert:NSLocalizedString(SyncMessageStart, nil)];
            }
        } else {
            [self showAlert:NSLocalizedString(@"No Internet Connection Available", nil)];
        }
    }
}

-(void)startNetworkActivityIndicator:(NSNotification*)notification {
    [self performSelectorOnMainThread:@selector(startNetworkActivityIndicator) withObject:nil waitUntilDone:NO];
}

-(void)startNetworkActivityIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)stopNetworkActivityIndicator:(NSNotification*)notification {
    [self performSelectorOnMainThread:@selector(stopNetworkActivityIndicator) withObject:nil waitUntilDone:NO];
}

-(void)stopNetworkActivityIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)addLoading:(NSNotification*)notification {
    NSString *message = (NSString*)notification.object;
    
    if (_progressHUD) {
        [_progressHUD removeFromSuperview];
        [_progressHUD hide:NO];
        _progressHUD = nil;
    }
    
    if (IS_OS_8_OR_LATER) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.window.rootViewController.view];
    } else {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.window];
    }
    
    _progressHUD.removeFromSuperViewOnHide = YES;
    if (message) {
        _progressHUD.labelText = [NSString stringWithFormat:@"Loading %@ ...", message];
        
    } else {
        _progressHUD.labelText = NSLocalizedString(@"Loading ...", nil);
    }
    
    _progressHUD.dimBackground = YES;
    
    if (IS_OS_8_OR_LATER) {
        [self.window.rootViewController.view addSubview:_progressHUD];
        [self.window.rootViewController.view bringSubviewToFront:_progressHUD];
    } else {
        [self.window addSubview:_progressHUD];
        [self.window bringSubviewToFront:_progressHUD];
    }
    
    [_progressHUD show:YES];
}

- (void)showSyncAlert:(NSString*)message {
    
    [self.banner dismissBannerWithOldStatusBarStyle:UIStatusBarStyleDefault];
    
    self.banner = [[BannerPlus alloc] initWithTitle:@"Notification"
                                          subtitle:message
                                             image:[UIImage imageNamed:@"SYNCNOW"]
                                   backgroundColor:[UIColor lightGrayColor]
                                       didTapBlock:^{
                                           NSLog(@"tapped");
                                           [self.banner dismissBannerWithOldStatusBarStyle:UIStatusBarStyleDefault];
                                           self.banner = nil;
                                       }];
    //[bannerView showBannerWithView:self.window duration:10];
    if ([message isEqualToString:SyncMessageEnd]) {
        [self.banner showBannerWithView:nil duration:10];
    } else {
        [self.banner showBannerWithView:nil duration:1000];
    }
}

- (void)showAlert:(NSString*)message {
    NSString *imageName = @"Icon-48x48";
    
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    if ([targetName isEqualToString:@"Water"]) {
        imageName = @"IRRIGATION.png";
    }

    self.banner = [[BannerPlus alloc] initWithTitle:@"Notification"
                                subtitle:message
                                   image:[UIImage imageNamed:imageName]
                         backgroundColor:[UIColor lightGrayColor]
                             didTapBlock:^{
                                 NSLog(@"tapped");
                                 [self.banner dismissBannerWithOldStatusBarStyle:UIStatusBarStyleDefault];
                                 self.banner = nil;
                             }];
    //[bannerView showBannerWithView:self.window duration:10];
    [self.banner showBannerWithView:nil duration:10];
}

-(void) setLoadingMessage:(NSString *) theMsg {
    if( _progressHUD ) {
        _progressHUD.labelText = theMsg;
    }
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) handleCrashReport {
#if TARGET_IPHONE_SIMULATOR
#else
//    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
//    NSError *error;
//
//	// Try loading the crash report
//	self.crashData = [NSData dataWithData:[crashReporter loadPendingCrashReportDataAndReturnError: &error]];
//	if (_crashData == nil) {
//		NSLog(@"Could not load crash report: %@", error);
//		//goto finish;
//        [crashReporter purgePendingCrashReport];
//        return;
//	}
//
//    // We could send the report from here, but we'll just print out
//    // some debugging info instead
//    PLCrashReport *report = [[PLCrashReport alloc] initWithData: _crashData error: &error];
//    if (report == nil) {
//        NSLog(@"Could not parse crash report");
//        //goto finish;
//        [crashReporter purgePendingCrashReport];
//        return;
//    }
//
//    NSLog(@"Crashed on %@", report.systemInfo.timestamp);
//    NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name,
//          report.signalInfo.code, report.signalInfo.address);
//
//    // Purge the report
//finish:
//    [crashReporter purgePendingCrashReport];
#endif
    return;
}

- (void) finishCrashLog
{
	[self initViews];
}

- (NSData *)getCrashData
{
	return _crashData;
}

#pragma mark - view controllers
- (void)initViews
{
    _memoryWarningReached = NO;
    
    // Override point for customization after application launch.
    LaunchMenuViewController *controller = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller = [[LaunchMenuViewController alloc] initWithNibName:@"LaunchMenuViewController_iPad"
                                                                bundle:nil];
        self.navController = [[UICustomNavControllerViewController alloc] initWithRootViewController:controller];
    }
    else {
        controller = [[LaunchMenuViewController alloc] initWithNibName:@"LaunchMenuViewController_iPhone"
                                                                bundle:nil];
        self.navController = [[UICustomNavControllerViewController alloc] initWithRootViewController:controller];
    }
    
    [self.navController setNavigationBarHidden:YES];
    
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
}

- (UINavigationController*)getDetailNavigationController {
    
    if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitViewController = (UISplitViewController*)self.window.rootViewController;
        UINavigationController *detailNavController = (UINavigationController*)[splitViewController.viewControllers objectAtIndex:1];
        return detailNavController;
    } else {
        return nil;
    }
}

- (UINavigationController*)setDetailController: (UIViewController *) detailController {
    
    UINavigationController *detailNavController = [self getDetailNavigationController];
    if( detailNavController != nil ) {
        [detailNavController popToRootViewControllerAnimated:NO];
        [detailNavController pushViewController:detailController animated:NO];

    }
    return detailNavController;
}

@end
