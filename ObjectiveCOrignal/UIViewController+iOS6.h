//
//  UIViewController+iOS6.h
//  Jobs
//
//  Created by .D. .D. on 2/4/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (iOS6)
- (void)dismissModalViewControllerAnimatediOS6:(BOOL)animated;
- (void)presentModalViewControlleriOS6:(UIViewController *)modalViewController animated:(BOOL)animated;
- (CGFloat)getNavigationBarHeight:(UIInterfaceOrientation)orientation;
- (CGFloat)getStartingCoordinateY:(UIInterfaceOrientation)orientation;

@end
