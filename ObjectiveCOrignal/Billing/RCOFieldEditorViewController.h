//
//  RCOFieldEditorViewController.h
//  MobileOffice
//
//  Created by .R.H. on 11/16/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MBProgressHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIViewController+iOS6.h"
#import "UINavigationController+Rotation_iOS6.h"
#import "BaseViewController.h"

#define PROGRESSHUD_TAG 9999
#define SHEET_ACTIONS 1112
#define FULL_SYNC_TAG 1113

#define FULL_SYNC_MESSAGE @"Do you really want to start a full sync for %@? While the full sync is in progress %@ are not available. Duration of full sync depends on the number of %@"


@class RCOObjectEditorViewController;

// listeners who want to get messages must subscribe to RCODataDelegate protocol
@protocol RCOFieldEditor <NSObject>
- (void) setEditorDelegate: (RCOObjectEditorViewController *) theDelegate withValue: (NSObject *) theValue forKey: (NSString *) theKey;
@end


@interface RCOFieldEditorViewController : BaseViewController <RCOFieldEditor, MBProgressHUDDelegate>
{
    RCOObjectEditorViewController *m_fieldEditingDelegate;
    UIPopoverController *m_popoverController;
    NSString *_key;
    NSObject *_val;
    NSObject *_initialVal;
    Boolean _dirty;
    Boolean m_isEditingField;
    Boolean m_isSelectToSave;
    
    MBProgressHUD *_progressHUD;
    BOOL isLoadingShown; 
    BOOL isForcedReload;
}

@property (nonatomic, strong) RCOObjectEditorViewController *fieldEditingDelegate;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSObject *val;
@property (nonatomic, strong) NSObject *initialVal;
@property (nonatomic, strong) NSMutableDictionary *objDict;
@property (nonatomic, strong) NSMutableDictionary *linkedControls;

@property (nonatomic, assign) Boolean dirty;
@property (nonatomic, assign) Boolean isEditingField;
@property (nonatomic, assign) Boolean isSelectToSave;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) NSDictionary *keyboardInfo;

- (void) showHideLoadIndicator;
- (void) saveButtonPressed: (id) sender;
- (void) cancelButtonPressed: (id) sender;
- (IBAction)actionButtonPressed:(id)sender;
- (void)showSimpleMessage:(NSString*)message;
- (void)showSimpleMessage:(NSString*)message andTitle:(NSString*)title;
- (void)showSimpleMessage:(NSString*)message andTitle:(NSString*)title closeButtonName:(NSString*)btnName;
- (void)hideSimpleMessagePopup;

@end
