//
//  BaseViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 5/4/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddObject.h"

#define kDefaultPageHeight 1242
#define kDefaultPageWidth  960

@interface BaseViewController : UIViewController <UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate> {
    BOOL _shouldDismissPopover;
}

@property (nonatomic, weak) id <AddObject> addDelegate;
@property (nonatomic, strong) NSString *addDelegateKey;
@property (nonatomic, strong) NSDictionary *keyboardInfo;
@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;

- (void)showPopoverForViewController:(UIViewController*)viewController fromView:(UIView*)fromView;

- (void)showPopoverForViewController:(UIViewController*)viewController fromView:(UIView*)fromView sourceRect:(CGRect)sourceRect;
- (void)showPopoverForNavigationViewController:(UINavigationController*)navController fromView:(UIView*)fromView sourceRect:(CGRect)sourceRect;

- (void)showPopoverForViewController:(UIViewController*)viewController fromView:(UIView*)fromView andDirection:(NSUInteger)direction;

- (void)showPopoverForViewController:(UIViewController*)viewController fromBarButton:(UIBarButtonItem*)fromBarButton;
- (void)showPopoverForNavigationViewController:(UIViewController*)navController fromBarButton:(UIBarButtonItem*)fromBarButton;

- (void)showPopoverModalForViewController:(UIViewController*)viewController;
- (void)showSimpleMessage:(NSString*)message;
- (void)showSimpleMessageSeparate:(NSString*)message ;
- (void)showSimpleMessageAndHide:(NSString*)message;

@end
