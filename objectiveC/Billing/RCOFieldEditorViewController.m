//
//  RCOFieldEditorViewController.m
//  MobileOffice
//
//  Created by .R.H. on 11/16/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "RCOFieldEditorViewController.h"
#import "RCOObjectEditorViewController.h"
//#import "MBProgressHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIColor+TKCategory.h"

@interface RCOFieldEditorViewController()
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) UIAlertController *alert1;
@end

@implementation RCOFieldEditorViewController

@synthesize fieldEditingDelegate = m_fieldEditingDelegate;
@synthesize popoverController=m_popoverController;
@synthesize val = _val;
@synthesize initialVal = _initialVal;
@synthesize key = _key;
@synthesize dirty= _dirty;
@synthesize isEditingField=m_isEditingField;
@synthesize isSelectToSave=m_isSelectToSave;
@synthesize progressHUD = _progressHUD;


#pragma mark -
#pragma mark Construction/Desctruction
- (void) dealloc
{
    _val = nil;
}
#pragma mark -
#pragma mark Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.progressHUD.delegate = self;

#ifdef IOS_7
    if (IS_OS_7_OR_LATER)
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    [[UIToolbar appearance] setBarTintColor:[UIColor toolBarColor]];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor navigationBarTitleColor]}];
}

- (void)viewDidUnload
{
    self.fieldEditingDelegate = nil;
    self.popoverController = nil;
    self.val = nil;
    self.initialVal = nil;
    self.key = nil;
    
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    if( self.isEditingField && !self.isSelectToSave )
    {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
        self.navigationItem.rightBarButtonItem = saveButton; 
        
        self.dirty = false;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel  target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.leftBarButtonItem = cancelButton; 
    }
    [super viewWillAppear:animated];
    
    self.progressHUD.dimBackground = YES;
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.progressHUD.frame = frame;
}


#pragma mark -
#pragma mark val/key handling

- (void) setEditorDelegate: (RCOObjectEditorViewController *) theDelegate withValue: (NSObject *) theValue forKey: (NSString *) theKey
{
    self.fieldEditingDelegate=theDelegate;
    self.initialVal = theValue;
    self.val = theValue;
    self.key = theKey;
 
    self.isEditingField=true;
}

- (void) setDirty:(Boolean)dirty
{
    _dirty=dirty;
    
    [self.navigationItem.rightBarButtonItem setEnabled:dirty];
    
}

-(void) setVal:(NSObject *)val
{
    self.dirty = ! [val isEqual:self.initialVal];
    
    _val = val;
}

#pragma mark - Button actions

- (IBAction)actionButtonPressed:(id)sender {
    
}
- (void) saveButtonPressed: (id) sender {
    
    if( self.fieldEditingDelegate && self.dirty)
    {
        self.dirty = false;
        [self.fieldEditingDelegate setObjectValue: self.val forKey: self.key];
    }
    
    [self cancelButtonPressed:self];
}

-(void) cancelButtonPressed:(id)sender {
    
    if( self.popoverController != nil )
        [self.popoverController dismissPopoverAnimated:YES];
    else
        if (DEVICE_IS_IPHONE) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    
    if (sender != self) {
        // cancel button was tapped
        if ([self.fieldEditingDelegate respondsToSelector:@selector(cancelObjectEdits)]) {
            [self.fieldEditingDelegate cancelObjectEdits];
        } else {
            NSLog(@"---%@-- does not respond to --cancelObjectEdits--", self.fieldEditingDelegate);
        }
    } else {
        // cancel was called from saveButton
    }

    if ([self.fieldEditingDelegate respondsToSelector:@selector(closePopover)]) {
        //[self.fieldEditingDelegate closePopover];
        [self.fieldEditingDelegate performSelector:@selector(closePopover)
                                        withObject:nil
                                        afterDelay:0.1];
    }
}

#pragma mark - loading indicator
- (void) showHideLoadIndicator
{
    // could do this with isLoadingShown toggle? 
    // isLoadingShown=self.progressHUD.alpha < 1.0f;
    
    if (isForcedReload) {
        isForcedReload = NO;
        self.progressHUD.dimBackground = YES;
        [self.view addSubview:self.progressHUD];
        [self.progressHUD show:YES];
        
        self.progressHUD.labelText = @"Synchronizing with the server";
        isLoadingShown = YES;
    } else {
        
        if (isLoadingShown) {
            [self.progressHUD hide:YES];
            isLoadingShown = NO;
        } else {
            [self.view addSubview:self.progressHUD];
            self.progressHUD.dimBackground = YES;
            [self.progressHUD show:YES];
            self.progressHUD.labelText = @"Synchronizing with the server";
            isLoadingShown = YES;
        }
    }
}

- (void)showSimpleMessage:(NSString*)message {
    return [self showSimpleMessage:message andTitle:NSLocalizedString(@"Notification", nil)];
}

- (void)showSimpleMessage:(NSString*)message andTitle:(NSString*)title closeButtonName:(NSString*)btnName{
    if (title.length == 0) {
        title = NSLocalizedString(@"Notification", nil);
    }

    if (btnName.length == 0) {
        btnName = NSLocalizedString(@"OK", nil);
    }

    if (self.alert1 && self.alert1.isBeingPresented) {
        [self.alert1 setMessage:message];
    } else {
        self.alert1 = [UIAlertController alertControllerWithTitle:title
                                                          message:message
                                                   preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* OKAction = [UIAlertAction actionWithTitle:btnName
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"");
                                                         }];
        
        [self.alert1 addAction:OKAction];
        [self presentViewController:self.alert1 animated:YES completion:nil];
    }

}

- (void)showSimpleMessage:(NSString*)message andTitle:(NSString*)title {
    
    if (!title) {
        title = NSLocalizedString(@"Notification", nil);
    }
    /*
    if (self.alert && self.alert.visible) {
        [self.alert setMessage:message];
    } else {
        self.alert = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
        [self.alert show];
    }
    */
    if (self.alert1 && self.alert1.isBeingPresented) {
        [self.alert1 setMessage:message];
    } else {
        self.alert1 = [UIAlertController alertControllerWithTitle:title
                                                          message:message
                                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"");
                                                         }];
        
        [self.alert1 addAction:OKAction];
        [self presentViewController:self.alert1 animated:YES completion:nil];
    }
}

-(void)hideSimpleMessagePopup {
    if (self.alert && self.alert.visible) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    }

    if (self.alert1 && self.alert1.isBeingPresented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
