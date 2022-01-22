//
//  SignatureViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 4/22/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

@interface SignatureViewController : HomeBaseViewController <UIGestureRecognizerDelegate>{
    NSString *_currentJob;
    CGPoint lastPoint;
    CGPoint firstPoint;
    UIPanGestureRecognizer *_panel;
}

@property (nonatomic, strong) IBOutlet UIImageView *signatureView;
@property (nonatomic, assign) BOOL returnOnlyImage;
@property (nonatomic, assign) UIImage *signatureImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forJob:(NSString*)job;

-(IBAction)clearPressed:(id)sender;

@end
