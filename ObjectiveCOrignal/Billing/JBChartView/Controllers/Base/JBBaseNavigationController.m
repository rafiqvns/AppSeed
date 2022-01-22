//
//  JBBaseNavigationController.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/7/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBBaseNavigationController.h"
#import "JBColorConstants.h"

@implementation JBBaseNavigationController

#pragma mark - Alloc/Init

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        self.navigationBar.translucent = NO;
        
#ifdef IOS_7
        if (IS_OS_7_OR_LATER) {
            [[UINavigationBar appearance] setBarTintColor:kJBColorNavigationTint];
            [[UINavigationBar appearance] setTintColor:kJBColorNavigationBarTint];
            self.interactivePopGestureRecognizer.enabled = NO;
        }
#endif

    }
    return self;
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
#ifdef IOS_7
    if (IS_OS_7_OR_LATER) {
        return UIStatusBarStyleLightContent;
    }
#endif

    return 0;
}

@end
