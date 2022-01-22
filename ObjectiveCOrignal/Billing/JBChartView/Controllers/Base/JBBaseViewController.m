//
//  JBBaseViewController.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/7/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBBaseViewController.h"
#import "JBUIConstants.h"

@interface JBBaseViewController ()

@end

@implementation JBBaseViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
#ifdef IOS_7
    if (IS_OS_7_OR_LATER)
        self.edgesForExtendedLayout = UIRectEdgeTop;
#endif

    self.view.backgroundColor = [UIColor whiteColor];
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kJBImageIconJawboneLogo]];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationMaskPortrait;
    
#ifdef UIInterfaceOrientationMaskAll
    return UIInterfaceOrientationMaskAll;
#else
    typedef enum {
        UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
        UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
        UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
        UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
        UIInterfaceOrientationMaskLandscape =
        (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
        UIInterfaceOrientationMaskAll =
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
        UIInterfaceOrientationMaskAllButUpsideDown =
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight),
    } UIInterfaceOrientationMask;
    
    return UIInterfaceOrientationMaskAll;
#endif

}

#pragma mark - Getters

- (UIBarButtonItem *)chartToggleButtonWithTarget:(id)target action:(SEL)action
{
    return nil;
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kJBImageIconArrow] style:UIBarButtonItemStylePlain target:target action:action];
    return button;
    
}


@end
