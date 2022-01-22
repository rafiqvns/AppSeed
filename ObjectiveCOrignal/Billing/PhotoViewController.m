//
//  PhotoViewController.m
//  Jobs
//
//  Created by .D. .D. on 2/19/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "PhotoViewController.h"
//#import "GTMHTTPFetcher.h"
//#import "GTLServiceDrive.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

@synthesize photoImage;
@synthesize photoImageView;

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
    // Do any additional setup after loading the view from its nib.
    if (self.photoURL) {
        [self.activityIndicator startAnimating];
        [self dowloadFile:self.photoURL];
    } else {
        self.photoImageView.image = self.photoImage;
        if (self.photoImage) {
            [self.activityIndicator setHidden:YES];
        }
    }
    if (self.addDelegate) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(closeButtonPressed:)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
}

-(void)closeButtonPressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(void)dowloadFile:(NSString*)fileURLString {
    /*
    GTMHTTPFetcher *fetcher =
    [self.driveService.fetcherService fetcherWithURLString:fileURLString];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            self.photoImageView.image = [UIImage imageWithData:data];
        } else {
            NSLog(@"An error occurred: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                            message:@"Unable to load file"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
    }];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    if ([self.activityIndicator isAnimating]) {
        [self.activityIndicator stopAnimating];
    }
}

@end
