//
//  BillingAppDelegate.h
//  Billing
//
//  Created by Thomas Smallwood on 6/17/11.
//  Copyright 2011 RCO All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomNavControllerViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define kMobileOfficeKey_MOC   @"MobileOffice_ThreadSpecificMOC"

@interface BillingAppDelegate : NSObject <UIApplicationDelegate> {
    UICustomNavControllerViewController *navController;
    MBProgressHUD *_progressHUD;
    
@private
	
	NSData *_crashData;								// holds the last crash report
    
	time_t _memoryWarningTimestamp;		// timestamp when memory warning appeared, we check on terminate if that timestamp is within a reasonable range to avoid false alarms
	BOOL _memoryWarningReached;				// true if memory warning notification is run at least once
	int _startupFreeMemory;						// amount of memory available at startup
	int _lastStartupFreeMemory;				// free memory at the last startup run
    
	int	_crashReportAnalyzerStarted;	// flags if the crashlog analyzer is started. since this may crash we need to track it
	int _shutdownFreeMemory;					// amount of memory available at shutdown
	int _lastShutdownFreeMemory;			// free memory at the last shutdown run
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) NSString *currentButton;
@property (nonatomic, strong) UIViewController *baseViewController;



- (NSURL *)applicationDocumentsDirectory;


- (NSData *)getCrashData;
- (void) finishCrashLog;

- (UINavigationController*)getDetailNavigationController;
- (UINavigationController*)setDetailController: (UIViewController *) detailController;

- (void)hideDisplayingAlert;

- (void)showAlert:(NSString*)message;
- (void)showSyncAlert:(NSString*)message;

@end
