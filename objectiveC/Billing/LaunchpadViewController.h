//
//  LaunchpadViewController.h
//  Billing3
//
//  Created by Thomas Smallwood on 8/7/11.
//  Copyright 2011 RCO All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaunchpadMenuViewController.h"
#import "OCPinPad.h"

@interface LaunchpadViewController : UIViewController <UIScrollViewDelegate, LaunchpadMenuDelegate, OCPinPadDelegate> {
    UIScrollView *scrollView;
	UIPageControl *pageControl;
    NSMutableArray *viewControllers;
	
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    NSUInteger numIncorrect;
    LaunchpadMenuViewController *controller;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) IBOutlet UIView *landscapeView;
@property (nonatomic, retain) IBOutlet UIView *portraitView;

- (IBAction)changePage:(id)sender;

- (void) launchChildController: (UIViewController*) controller;

@end
