//
//  HomeBaseViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 4/22/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+iOS6.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCOObjectEditorViewController.h"
#import <MessageUI/MessageUI.h>

#define PROGRESSHUD_TAG 9999

#define EMAIL_SUBJECT @"emailSubject"
#define EMAIL_CONTENT @"emailContent"
#define EMAIL_CONTENTPLAIN @"emailContentPlain"

@interface HomeBaseViewController : RCOObjectEditorViewController <MBProgressHUDDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate> {
}

@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, assign) BOOL isPreview;
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, weak) id<RCOSpliterSelectionDelegate, RCOSpliterEditorDelegate> selectionDelegate;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

- (void)registerCallbacks;
- (void)unRegisterCallbacks;
- (void)sendEmail:(NSDictionary*)params;
- (IBAction)actionButtonPressed:(id)sender;
- (void)showMessage:(NSString*)message;
- (void)homePressed:(id)sender;

-(void)unregisterKeyboardEvents;
-(void)registerKeyboardEvents;

@end
