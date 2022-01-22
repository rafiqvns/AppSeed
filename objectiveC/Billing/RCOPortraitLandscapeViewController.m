//
//  RCOPortraitLandscapeViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 11/28/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "RCOPortraitLandscapeViewController.h"
#import "Settings.h"

@interface RCOPortraitLandscapeViewController ()

@end

@implementation RCOPortraitLandscapeViewController

@synthesize landscapeView;
@synthesize portraitView;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self loadPortraitViews];
    } else  if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self loadLandscapeViews];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (DEVICE_IS_IPAD) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGRect frame = self.view.frame;
            frame.size.height = 960;
            self.view.frame = frame;
        } else  if (UIInterfaceOrientationIsLandscape(orientation)) {
            CGRect frame = self.view.frame;
            frame.size.height = 704;
            self.view.frame = frame;
        }
        [self.view layoutSubviews];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)loadPortraitViews {
    
    if (DEVICE_IS_IPHONE) {
        // we don't need to rotate if is Iphone
        return;
    }
    
    CGRect frame = self.view.frame;
    
    if (DEVICE_IS_IPAD) {
        frame.size.height = 960;
        self.view.frame = frame;
        [self.view layoutSubviews];
    }
    
    NSArray *subviews = self.view.subviews;
    
    double delta = frame.size.width / self.portraitView.frame.size.width;
    
    for (int i = 0; i < [subviews count]; i++) {
        UIView *subView = [subviews objectAtIndex:i];
        UIView *portraitViewTmp = [self.portraitView viewWithTag:subView.tag];
        
        CGRect newFrame = portraitViewTmp.frame;
        newFrame.size.width *= delta;
        newFrame.origin.x *=delta;
        
        subView.frame = newFrame;
        
        if (subView.tag == 100) {
            // this is the backgound
            UIImageView *bg = (UIImageView*)subView;
            bg.image = [UIImage imageNamed:@"iPad_background_wood_portrait.png"];
            bg.contentMode = UIViewContentModeScaleToFill;
        }
        
        if (subView.tag == 104) {
            // this is the frame
            
            NSString *frameImgName = [Settings getThemeImageNameOfType:@"border"
                                                        forOrientation:UIInterfaceOrientationPortrait];
            UIImage *frameImage = [UIImage imageNamed:frameImgName];
            
            UIImageView *bg = (UIImageView*)subView;
            bg.image = frameImage;

            bg.contentMode = UIViewContentModeRight;
        }
    }
}

-(void)loadLandscapeViews {
    
    if (DEVICE_IS_IPHONE) {
        // we don't need to rotate if is Iphone
        return;
    }
    
    CGRect frame = self.view.frame;
    
    if (DEVICE_IS_IPAD) {
        frame.size.height = 704;
        self.view.frame = frame;
        [self.view layoutSubviews];
    }
    
    NSArray *subviews = self.view.subviews;
    
    double delta = frame.size.width / self.landscapeView.frame.size.width;
        
    for (int i = 0; i < [subviews count]; i++) {
        UIView *subView = [subviews objectAtIndex:i];
        UIView *landscapeViewTmo = [self.landscapeView viewWithTag:subView.tag];
        
        CGRect newFrame = landscapeViewTmo.frame;
        newFrame.size.width *= delta;
        newFrame.origin.x *=delta;
        
        subView.frame = newFrame;
        if (subView.tag == 100) {
            // this is the backgound
            UIImageView *bg = (UIImageView*)subView;
            bg.image = [UIImage imageNamed:@"iPad_background_wood_landscape.png"];
            bg.contentMode = UIViewContentModeScaleToFill;
        }
        
        if (subView.tag == 104) {
            // this is the frame
            UIImageView *bg = (UIImageView*)subView;
            NSString *frameImgName = [Settings getThemeImageNameOfType:@"border"
                                                        forOrientation:UIInterfaceOrientationLandscapeLeft];
            UIImage *frameImage = [UIImage imageNamed:frameImgName];
            
            bg.image = frameImage;

            bg.contentMode = UIViewContentModeRight;
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
        (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
        /*if (DEVICE_IS_IPAD)*/ {
            [self loadPortraitViews];
        }
    } else {
        /*if (DEVICE_IS_IPAD)*/ {
            [self loadLandscapeViews];
        }
    }
}

@end
