//
//  BaseViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 5/4/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "BaseViewController.h"
#import "UIColor+TKCategory.h"

@interface BaseViewController ()
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) UIAlertView *alertWithAutoHide;
@property (nonatomic, strong) UIAlertController *alertWithAutoHide1;
@end

#define TAG_ALERT_AUTO_CLOSE -225577

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (DEVICE_IS_IPHONE) {
        // we need a done button to close the keyboard on iphone
        self.keyboardToolbar = [[UIToolbar alloc] init];
        
        [self.keyboardToolbar sizeToFit];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(doneClicked:)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
        [self.keyboardToolbar setItems:[NSArray arrayWithObjects:space, doneButton, nil]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    // This should be overwritten
}

- (void)keyboardWillShow:(NSNotification *)notif{
    // This should be overwritten
}

-(void)doneClicked:(id)sender {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showPopoverForViewController:(UIViewController*)viewController fromBarButton:(UIBarButtonItem*)fromBarButton {
    
    if (!fromBarButton){
        // 07.09.2018
#ifndef APPLE_STORE
        [self showSimpleMessage:@"Popover Exception"];
#endif
        return;
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if (DEVICE_IS_IPAD) {
        [navController setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popController = [navController popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.barButtonItem = fromBarButton;
    }

    [self presentViewController:navController animated:YES completion:nil];
    /*
    
    if (0) {
        ////[self.popoverCtrl dismissPopoverAnimated:YES];
    }
    
    self.popoverCtrl = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    self.popoverCtrl.delegate = self;
    
    [self.popoverCtrl presentPopoverFromBarButtonItem:fromBarButton
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
    */
}

- (void)showPopoverForNavigationViewController:(UIViewController*)navController fromBarButton:(UIBarButtonItem*)fromBarButton {
    if (DEVICE_IS_IPAD) {
        [navController setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popController = [navController popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.barButtonItem = fromBarButton;
    }
    
    [self presentViewController:navController animated:YES completion:nil];
}


-(void)showPopoverForViewController:(UIViewController*)viewController fromView:(UIView*)fromView sourceRect:(CGRect)sourceRect{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if (DEVICE_IS_IPAD) {
        [navController setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popController = [navController popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.sourceView = fromView;
        popController.sourceRect = sourceRect;
    }
    
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)showPopoverForNavigationViewController:(UINavigationController*)navController fromView:(UIView*)fromView sourceRect:(CGRect)sourceRect{
    if (DEVICE_IS_IPAD) {
        [navController setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popController = [navController popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.sourceView = fromView;
        popController.sourceRect = sourceRect;
    }
    
    [self presentViewController:navController animated:YES completion:nil];
}


-(void)showPopoverForViewController:(UIViewController*)viewController fromView:(UIView*)fromView {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    CGRect bounds = fromView.bounds;
    bounds.origin.x = bounds.size.width/2;
    bounds.size.width = 0;

    
    if (DEVICE_IS_IPAD) {
        [navController setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popController = [navController popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.sourceView = fromView;
        popController.sourceRect = bounds;
    }
    
    [self presentViewController:navController animated:YES completion:nil];

    return;
    /*
    if (self.popoverCtrl .popoverVisible) {
        ////[self.popoverCtrl dismissPopoverAnimated:YES];
    }
    
    self.popoverCtrl = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    self.popoverCtrl.delegate = self;
    
    [self.popoverCtrl presentPopoverFromRect:bounds
                                      inView:fromView
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    */
}

-(void)showPopoverForViewController:(UIViewController*)viewController fromView:(UIView*)fromView andDirection:(NSUInteger)direction{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    CGRect bounds = fromView.bounds;
    bounds.origin.x = bounds.size.width/2;
    bounds.size.width = 0;

    
    if (DEVICE_IS_IPAD) {
        [navController setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popController = [navController popoverPresentationController];
        popController.permittedArrowDirections = direction;
        popController.delegate = self;
        popController.sourceView = fromView;
        popController.sourceRect = bounds;
    }
    
    [self presentViewController:navController animated:YES completion:nil];
/*
    
    
    
    
    self.popoverCtrl = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    self.popoverCtrl.delegate = self;
    
    self.popoverCtrl.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // 22.12.2015 fixing the issue with the popover that was not being displayed from the left side or right side beceause was not fitting in the screen
    
    [self.popoverCtrl presentPopoverFromRect:bounds
                                      inView:fromView
                    permittedArrowDirections:direction
                                    animated:YES];
 */
}

-(void)showPopoverModalForViewController:(UIViewController*)viewController{
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarColor]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    self.isFullScreen = YES;

    if (DEVICE_IS_IPAD) {
        [navController setModalPresentationStyle:UIModalPresentationOverFullScreen];
        //[navController setModalPresentationStyle:UIModalPresentationPopover];

        [navController setPreferredContentSize:mainWindow.frame.size];
        // set content view controler size
        
        UIPopoverPresentationController *popController = [navController popoverPresentationController];
        popController.permittedArrowDirections = 0;
        popController.delegate = self;
        popController.sourceView = self.view;
        popController.sourceRect = mainWindow.frame;
        popController.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    [self presentViewController:navController animated:YES completion:nil];

    
  /*
   06.09.2018
    
    if (self.popoverCtrl .popoverVisible) {
        //[self.popoverCtrl dismissPopoverAnimated:NO];
    }
    
    self.popoverCtrl = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    self.isFullScreen = YES;
    
    self.popoverCtrl.popoverContentSize = mainWindow.frame.size;
    self.popoverCtrl.delegate = self;
    self.popoverCtrl.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _shouldDismissPopover = NO;
    if (IS_OS_8_OR_LATER) {
        [self.popoverCtrl presentPopoverFromRect:mainWindow.frame inView:self.view permittedArrowDirections:0 animated:YES];
    } else {
        [self.popoverCtrl presentPopoverFromRect:mainWindow.frame inView:mainWindow permittedArrowDirections:0 animated:YES];
    }
*/
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"Center = %@", NSStringFromCGPoint(self.view.center));
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

        /*
         06.09.2018
         we need a solution for this ...
        if (self.popoverCtrl.popoverVisible && self.isFullScreen) {
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            
            self.popoverCtrl.popoverContentSize = mainWindow.frame.size;
        }
        */
        
        if (self.isFullScreen) {
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];

            UINavigationController *nav = (UINavigationController*)self.presentedViewController;
            [nav setPreferredContentSize:mainWindow.frame.size];
        }
    } completion:nil];
}

-(void)showSimpleMessage:(NSString*)message {
    if (message) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"");
                                                         }];
        
        [ac addAction:OKAction];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)showSimpleMessageSeparate:(NSString*)message  {
    if (message) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"");
                                                         }];
        
        [ac addAction:OKAction];
        [self presentViewController:ac animated:YES completion:nil];

    }
}

- (void)showSimpleMessageAndHide:(NSString*)message {
    if (self.alertWithAutoHide.isVisible) {
        [self.alertWithAutoHide dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    if (self.alertWithAutoHide1.isBeingPresented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    self.alertWithAutoHide = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    self.alertWithAutoHide.tag = TAG_ALERT_AUTO_CLOSE;
    
    [self.alertWithAutoHide show];

    [self performSelector:@selector(closeFinishSyncAlert:) withObject:nil afterDelay:2];
}

-(void)closeFinishSyncAlert:(id)sender {
    if (self.alertWithAutoHide.visible) {
        if (self.alertWithAutoHide.tag == TAG_ALERT_AUTO_CLOSE) {
            [self.alertWithAutoHide dismissWithClickedButtonIndex:0 animated:NO];
        }
    }
}

@end
