//
//  MyViewController.m
//  Billing3
//
//  Created by Thomas Smallwood on 8/7/11.
//  Copyright 2011 RCO All rights reserved.

#import "LaunchpadMenuViewController.h"

@implementation LaunchpadMenuViewController

@synthesize pageNumberLabel;

@synthesize viewPortrait1;
@synthesize viewPortrait2;

@synthesize viewLandscape1;
@synthesize viewLandscape2;

@synthesize delegate;

@synthesize launchPadRectArray;
@synthesize launchPadLandscapeRectArray;

- (void)setUpLaunchPad {
    self.launchPadRectArray = [[NSArray alloc] initWithObjects:[NSValue valueWithCGRect:CGRectMake(5, 37, 100, 100)], 
                               [NSValue valueWithCGRect:CGRectMake(110, 37, 100, 100)], 
                               [NSValue valueWithCGRect:CGRectMake(220, 37, 100, 100)], 
                               [NSValue valueWithCGRect:CGRectMake(5, 170, 100, 100)], 
                               [NSValue valueWithCGRect:CGRectMake(110, 170, 100, 100)], 
                               [NSValue valueWithCGRect:CGRectMake(220, 170, 100, 100)], 
                               [NSValue valueWithCGRect:CGRectMake(5, 300, 100, 100)], 
                               [NSValue valueWithCGRect:CGRectMake(110, 300, 100, 100)], 
                               [NSValue valueWithCGRect:CGRectMake(220, 300, 100, 100)], nil];

    self.launchPadLandscapeRectArray = [[NSArray alloc] initWithObjects:
                                        [NSValue valueWithCGRect:CGRectMake(5, 37, 100, 100)], 
                                       [NSValue valueWithCGRect:CGRectMake(110, 37, 100, 100)], 
                                       [NSValue valueWithCGRect:CGRectMake(220, 37, 100, 100)], 
                                       [NSValue valueWithCGRect:CGRectMake(330, 37, 100, 100)], 
                                       [NSValue valueWithCGRect:CGRectMake(5, 170, 100, 100)], 
                                       [NSValue valueWithCGRect:CGRectMake(110, 170, 100, 100)], 
                                       [NSValue valueWithCGRect:CGRectMake(220, 170, 100, 100)], 
                                       [NSValue valueWithCGRect:CGRectMake(330, 170, 100, 100)], 
                                       [NSValue valueWithCGRect:CGRectMake(5, 300, 100, 100)], nil];
    
    //////// VIEW 1 /////////
    
    //customer button
    UIButton *customerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customerButton setImage:[UIImage imageNamed:@"wood_Customers_iPad.png"] forState:UIControlStateNormal];
    [customerButton addTarget:self action:@selector(launchClientListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //staff button
    UIButton *staffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [staffButton setImage:[UIImage imageNamed:@"wood_Staff_iPad.png"] forState:UIControlStateNormal];
    [staffButton addTarget:self action:@selector(launchStaffListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //vendors button
    UIButton *vendorsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [vendorsButton setImage:[UIImage imageNamed:@"wood_Vendors_iPad.png"] forState:UIControlStateNormal];
    [vendorsButton addTarget:self action:@selector(launchVendorsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //income button
    UIButton *incomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [incomeButton setImage:[UIImage imageNamed:@"wood_Income_iPad.png"] forState:UIControlStateNormal];
    //[incomeButton addTarget:self action:@selector(laun:) forControlEvents:UIControlEventTouchUpInside];
    
    //timecards button
    UIButton *timecardsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [timecardsButton setImage:[UIImage imageNamed:@"wood_Timecards_iPad.png"] forState:UIControlStateNormal];
    [timecardsButton addTarget:self action:@selector(launchTimecardsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //legal button
    UIButton *legalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [legalButton setImage:[UIImage imageNamed:@"wood_Legal_iPad.png"] forState:UIControlStateNormal];
    [legalButton addTarget:self action:@selector(launchLegalViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //charts button
    UIButton *chartsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [chartsButton setImage:[UIImage imageNamed:@"wood_Charts_iPad.png"] forState:UIControlStateNormal];
    [chartsButton addTarget:self action:@selector(launchChartsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //stores button
    UIButton *storesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [storesButton setImage:[UIImage imageNamed:@"wood_Stores_iPad.png"] forState:UIControlStateNormal];
    [storesButton addTarget:self action:@selector(launchStoreListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //parts button
    UIButton *partsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [partsButton setImage:[UIImage imageNamed:@"wood_Parts_iPad.png"] forState:UIControlStateNormal];
    [partsButton addTarget:self action:@selector(launchPartsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //////// VIEW 1 LANDSCAPE/////////
    
    //customer button
    UIButton *customerButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [customerButtonL setImage:[UIImage imageNamed:@"wood_Customers_iPad.png"] forState:UIControlStateNormal];
    [customerButtonL addTarget:self action:@selector(launchClientListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //staff button
    UIButton *staffButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [staffButtonL setImage:[UIImage imageNamed:@"wood_Staff_iPad.png"] forState:UIControlStateNormal];
    [staffButtonL addTarget:self action:@selector(launchStaffListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //vendors button
    UIButton *vendorsButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [vendorsButtonL setImage:[UIImage imageNamed:@"wood_Vendors_iPad.png"] forState:UIControlStateNormal];
    [vendorsButtonL addTarget:self action:@selector(launchVendorsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //income button
    UIButton *incomeButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [incomeButtonL setImage:[UIImage imageNamed:@"wood_Income_iPad.png"] forState:UIControlStateNormal];
    //[incomeButton addTarget:self action:@selector(laun:) forControlEvents:UIControlEventTouchUpInside];
    
    //timecards button
    UIButton *timecardsButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [timecardsButtonL setImage:[UIImage imageNamed:@"wood_Timecards_iPad.png"] forState:UIControlStateNormal];
    [timecardsButtonL addTarget:self action:@selector(launchTimecardsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //legal button
    UIButton *legalButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [legalButton setImage:[UIImage imageNamed:@"wood_Legal_iPad.png"] forState:UIControlStateNormal];
    [legalButton addTarget:self action:@selector(launchLegalViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //charts button
    UIButton *chartsButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [chartsButtonL setImage:[UIImage imageNamed:@"wood_Charts_iPad.png"] forState:UIControlStateNormal];
    [chartsButtonL addTarget:self action:@selector(launchChartsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //stores button
    UIButton *storesButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [storesButtonL setImage:[UIImage imageNamed:@"wood_Stores_iPad.png"] forState:UIControlStateNormal];
    [storesButtonL addTarget:self action:@selector(launchStoreListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //parts button
    UIButton *partsButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [partsButtonL setImage:[UIImage imageNamed:@"wood_Parts_iPad.png"] forState:UIControlStateNormal];
    [partsButtonL addTarget:self action:@selector(launchPartsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //////// VIEW 2 /////////
    
    //expenses button
    UIButton *expensesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [expensesButton setImage:[UIImage imageNamed:@"wood_Expenses_iPad.png"] forState:UIControlStateNormal];
    [expensesButton addTarget:self action:@selector(launchPaymentsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //invoices button
    UIButton *invoicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [invoicesButton setImage:[UIImage imageNamed:@"wood_Invoices_iPad.png"] forState:UIControlStateNormal];
    [invoicesButton addTarget:self action:@selector(launchInvoicesListViewController:) forControlEvents:UIControlEventTouchUpInside];

    //invoices button
    UIButton *invoicesButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [invoicesButtonL setImage:[UIImage imageNamed:@"wood_Invoices_iPad.png"] forState:UIControlStateNormal];
    [invoicesButtonL addTarget:self action:@selector(launchInvoicesListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //clipboard button
    UIButton *clipboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clipboardButton setImage:[UIImage imageNamed:@"wood_Clipboard_iPad.png"] forState:UIControlStateNormal];
    [clipboardButton addTarget:self action:@selector(launchClipboardViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //reports button
    UIButton *reportsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reportsButton setImage:[UIImage imageNamed:@"wood_Reports_iPad.png"] forState:UIControlStateNormal];
    [reportsButton addTarget:self action:@selector(launchReportsListViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    //settings button
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageNamed:@"wood_Settings_iPad.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(launchSettingsViewController:) forControlEvents:UIControlEventTouchUpInside];

    //settings button
    UIButton *settingsButtonL = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButtonL setImage:[UIImage imageNamed:@"wood_Settings_iPad.png"] forState:UIControlStateNormal];
    [settingsButtonL addTarget:self action:@selector(launchSettingsViewController:) forControlEvents:UIControlEventTouchUpInside];
    
        
    ////////////////////////////// CONFIGURE LAUNCHPAD ////////////////////////////////////////
    
    NSMutableArray *view1Array = [[NSMutableArray alloc] initWithObjects:customerButton, staffButton, vendorsButton, 
                                  timecardsButton, legalButton, storesButton, invoicesButton, settingsButton, nil];
    NSMutableArray *view1ArrayL = [[NSMutableArray alloc] initWithObjects:customerButtonL, staffButtonL, vendorsButtonL, 
                                  timecardsButtonL, legalButtonL, storesButtonL, invoicesButtonL, settingsButtonL, nil];
    
    NSMutableArray *view2Array = [[NSMutableArray alloc] initWithObjects:nil];
    
    
    ////////////////////////////// CONFIGURE END ////////////////////////////////////////
        
    for (int i = 0; i < [view1Array count]; i++) {
        UIButton *tempButton = [view1Array objectAtIndex:i];
        tempButton.frame = [[launchPadRectArray objectAtIndex:i] CGRectValue];
        [self.viewPortrait1 addSubview:tempButton];
        
        UIButton *tempButtonL = [view1ArrayL objectAtIndex:i];
        tempButtonL.frame = [[self.launchPadLandscapeRectArray objectAtIndex:i] CGRectValue];
        [self.viewLandscape1 addSubview:tempButtonL];
    }
    
    for (int i = 0; i < [view2Array count]; i++) {
        UIButton *tempButton = [view2Array objectAtIndex:i];
        tempButton.frame = [[launchPadRectArray objectAtIndex:i] CGRectValue];
        [self.viewPortrait2 addSubview:tempButton];
    }
    
    [view1Array release];
    [view1ArrayL release];
}

- (UIView *)pageControlViewWithIndex:(NSUInteger)index {
    
    
    if (index == 0) {
        [self.viewPortrait1 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grid_bg_pattern_1.png"]]];
        return self.viewPortrait1;
    }
    else {
        [self.viewPortrait2 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grid_bg_pattern_1.png"]]];
        return self.viewPortrait2;
    }
}

- (IBAction)launchClientListViewController:(id)sender {
    [self.delegate openClientListViewController];
}

- (IBAction)launchStaffListViewController:(id)sender {
    [self.delegate openStaffListViewController];
}

- (IBAction)launchVendorsListViewController:(id)sender {
    [self.delegate openVendorsListViewController];
}

- (IBAction)launchInvoicesListViewController:(id)sender {
}

- (IBAction)launchPaymentsListViewController:(id)sender {
}

- (IBAction)launchPartsListViewController:(id)sender {
    [self.delegate openPartsListViewController];
}

- (IBAction)launchChartsListViewController:(id)sender {
}

- (IBAction)launchReportsListViewController:(id)sender {
}

- (IBAction)launchTimecardsListViewController:(id)sender {
    [self.delegate openTimecardsViewController];
}

- (IBAction)launchSettingsViewController:(id)sender {
    [self.delegate openSettingsViewController];
}

- (IBAction)launchClipboardViewController:(id)sender {
}

- (IBAction)launchLegalViewController:(id)sender {
    //[self.delegate openDocumentsViewController];
}

- (IBAction)launchStoreListViewController:(id)sender {
    [self.delegate openStoreViewController];
}


// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)page {
    if ((self = [super initWithNibName:@"LaunchpadMenuViewController" bundle:nil]) != nil) {
        pageNumber = page;
    }
    return self;
}

- (void)dealloc {
    self.viewPortrait1 = nil;
    self.viewPortrait2 = nil;
    
    self.viewLandscape1 = nil;
    self.viewLandscape2 = nil;
    
    self.launchPadLandscapeRectArray = nil;
    self.launchPadRectArray = nil;
    
    [pageNumberLabel release];
    [super dealloc];
}

// Set the label and background color when the view has finished loading.
- (void)viewDidLoad {
    
    [self setUpLaunchPad];
    
    pageNumberLabel.text = [NSString stringWithFormat:@"Page %d", pageNumber + 1];
    
    [self.view addSubview:[self pageControlViewWithIndex:pageNumber]];
}

- (void)viewDidUnload {
    self.viewPortrait1 = nil;
    self.viewPortrait2 = nil;
    self.viewLandscape1 = nil;
    self.viewLandscape2 = nil;
    
    [super viewDidUnload];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || 
        (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
        self.view = self.viewPortrait1;
    } else {
        self.view = self.viewLandscape1;
    }
}

@end
