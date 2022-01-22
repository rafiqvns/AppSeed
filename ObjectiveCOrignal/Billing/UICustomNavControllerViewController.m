//
//  UICustomNavControllerViewController.m
//  MobileOffice
//
//  Created by Hari Wepuri on 9/27/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "UICustomNavControllerViewController.h"

@interface UICustomNavControllerViewController ()

@end

@implementation UICustomNavControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark -
#pragma mark iOS 6 Only

-(NSUInteger)supportedInterfaceOrientations
{
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
