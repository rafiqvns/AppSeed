//
//  TestViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/7/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "TestViewController.h"

@implementation TestViewController

@synthesize textField;
@synthesize passwordField;
@synthesize result;
@synthesize criptButton;
@synthesize data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _isCripting = YES;
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"Test";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)test:(id)sender {


}

-(IBAction)switchValues:(id)sender {
    NSString *title = nil;
    NSString *criptText = self.result.text;
    if (_isCripting) {
        title = @"Decript";
        _isCripting = NO;
    } else {
        title = @"Cript";
        _isCripting = YES;
    }
    
    self.textField.text = criptText;
    self.result.text = nil;
    
    [self.criptButton setTitle:title forState:UIControlStateNormal];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

-(void)criptFile:(NSString*)key {
    
}

-(void)decript:(NSString*)key {
    
    
}

-(IBAction)encriptFile:(id)sender {
    
}

-(IBAction)decriptFile:(id)sender {

}

@end
