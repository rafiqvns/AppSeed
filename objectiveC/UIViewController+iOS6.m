//
//  UIViewController+iOS6.m
//  Jobs
//
//  Created by .D. .D. on 2/4/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "UIViewController+iOS6.h"
#import "UIColor+TKCategory.h"

@implementation UIViewController (iOS6);
-(void)dismissModalViewControllerAnimatediOS6:(BOOL)animated {
#ifndef __IPHONE_6_0
    [self dismissModalViewControllerAnimated:animated];
#else
    [self dismissViewControllerAnimated:animated completion:nil];
#endif
}

- (void)presentModalViewControlleriOS6:(UIViewController *)modalViewController animated:(BOOL)animated {
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarColor]];
#ifndef __IPHONE_6_0
    [self presentModalViewController:modalViewController animated:animated];
#else
    //FIX
    modalViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:modalViewController animated:animated completion:nil];
#endif
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location > 0 && range.length == 1 && string.length == 0)
    {
        // iOS is trying to delete the entire string
        textField.text = [textField.text substringToIndex:textField.text.length - 1];
        SEL theSelector = @selector(textFieldChanged:);
        if ([self respondsToSelector:theSelector]) {
            [self performSelector:theSelector withObject:textField];
        }
        return NO;
    }
    return YES;
}

- (CGFloat)getNavigationBarHeight:(UIInterfaceOrientation)orientation {
    if (DEVICE_IS_IPAD) {
        return 44;
    }
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return 44;
    } else {
        return 32;
    }
}

- (CGFloat)getStartingCoordinateY:(UIInterfaceOrientation)orientation {
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    
    double navigationBarHeight = [self getNavigationBarHeight:orientation];
    
    CGFloat y = 0;
    if (self.navigationController == mainWindow.rootViewController) {
        // if the root view controller is the same as navigation controller then we should subtract also the status bar. When pushing the list to root view controller the search bar was not shown entirely
        if (IS_OS_8_OR_LATER) {
            y = 20 + navigationBarHeight;
        } else {
            y = navigationBarHeight;
        }
    } else {
        y = navigationBarHeight;
        if (DEVICE_IS_IPHONE) {
            // if we are on iphone portarit we should add also the status bar height
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                y += 20;
            }
        }
    }
    return y;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
