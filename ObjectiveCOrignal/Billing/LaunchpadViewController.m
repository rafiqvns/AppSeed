//
//  LaunchpadViewController.m
//  Billing3
//
//  Created by Thomas Smallwood on 8/7/11.
//  Copyright 2011 RCO All rights reserved.
//

#import "LaunchpadViewController.h"
#import "LaunchpadMenuViewController.h"
#import "ClientListViewController.h"
#import "StaffListViewController.h"
#import "VendorListViewController.h"
#import "SettingsViewController.h"
#import "BillingAppDelegate.h"
#import "JobsListViewController.h"
#import "DataRepository.h"
#import "StoreViewController.h"

static NSUInteger kNumberOfPages = 1;

@interface LaunchpadViewController (PrivateMethods)

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation LaunchpadViewController

@synthesize scrollView, viewControllers, pageControl;
@synthesize landscapeView, portraitView;

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 */
- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grid_bg_pattern_1.png"]]];
	
	// view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
	
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
	
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notFirstLaunch"]) {
        NSLog(@"wawa");
        OCPinPad *pp = [[OCPinPad alloc] initWithCorrectPin:@"1234"];
        [pp setUseAppleSymbol:NO];
        [pp setInCreatePinMode:YES];
        [pp setTitle:@"Enter PIN"];
        [pp setDelegate:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pp];
        //[navController.navigationBar setHidden:YES];
        
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentModalViewController:navController animated:YES];
        [pp release];
        [navController release];
        
    }
    else {
        NSLog(@"ya");
        OCPinPad *pp = [[OCPinPad alloc] initWithCorrectPin:[[NSUserDefaults standardUserDefaults] valueForKey:@"pin"]];
        [pp setUseAppleSymbol:NO];
        [pp setInCreatePinMode:NO];
        [pp setTitle:@"Enter PIN"];
        [pp setDelegate:self];
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:pp];
        
        
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentModalViewController:navController animated:YES];
        [pp release];
        [navController release];
    }
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
	
    // replace the placeholder if necessary
    //LaunchpadMenuViewController *controller = [viewControllers objectAtIndex:page];
    controller = [viewControllers objectAtIndex:page];

    if ((NSNull *)controller == [NSNull null]) {
        controller = [[LaunchpadMenuViewController alloc] initWithPageNumber:page];
        [controller setDelegate:self];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        //[controller release];
    }
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

- (void) launchChildController: (UIViewController*) controller
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(goHome)];
    controller.navigationItem.leftBarButtonItem = homeButton;
    [homeButton release];
    [self presentModalViewController:navController animated:YES];
    [navController release];
}

- (void) goHome
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark --
#pragma mark LaunchpadMenuDelegate functions

- (void)openClientListViewController {
    ClientListViewController *cLVC = [[ClientListViewController alloc] initUserList];   
    [self launchChildController: cLVC];
    [cLVC release];
    
}

- (void)openStaffListViewController {
    StaffListViewController *slvc = [[StaffListViewController alloc] initUserList];    
    
    [self launchChildController: slvc];
    [slvc release];
}

- (void)openVendorsListViewController {
    VendorListViewController *vlvc = [[VendorListViewController alloc] initUserList];    
    
    [self launchChildController: vlvc];
    [vlvc release];
}

- (void)openSettingsViewController {
   
    SettingsViewController *sVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self launchChildController: sVC];
    [sVC release];
}
- (void)openTimecardsViewController {
    
    JobsListViewController *jobListVC = [[JobsListViewController alloc] initWithNibName:@"JobsListViewController" bundle:nil];
    if(!jobListVC.aggregate.synching)
        [self launchChildController: jobListVC];
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Timecards are still synching..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    }
    [jobListVC release];
}

- (void)openPartsListViewController {
    
}

- (void)openStoreViewController {
    
    StoreViewController *storeVC = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
    [self launchChildController: storeVC];
    [storeVC release];
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
        self.view = self.portraitView;
    } else {
        self.view = self.landscapeView;
    }
    [controller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
 

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {

	self.viewControllers = nil;
    self.scrollView = nil;
    self.pageControl = nil;

    [super viewDidUnload];
}


- (void)dealloc {
    [viewControllers release], viewControllers = nil;
    [scrollView release], scrollView = nil;
    [pageControl release], pageControl = nil;
    self.landscapeView = nil;
    self.portraitView = nil;
    [controller release], controller = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark OCPinPad delegate Methods

- (void)ocPinPadDidEnterCorrectPin:(OCPinPad *)opp {
    //	[self.navigationController setNavigationBarHidden:NO];
    //	LaunchpadViewController *lPVC = [[LaunchpadViewController alloc] initWithNibName:@"LaunchpadViewController" bundle:nil];
    //	[self.view addSubview:lPVC.view];
	
	numIncorrect = 0;
	[self dismissModalViewControllerAnimated:YES];
}

- (void)ocPinPadDidCancel:(OCPinPad *)opp {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)ocPinPadDidEnterIncorrectPin:(OCPinPad *)opp {
	numIncorrect++;
	[opp setIncorrectText:[NSString stringWithFormat:@"%d Failed Attempt%@", numIncorrect, (numIncorrect == 1 ? @"" : @"s")]];
	
	if (numIncorrect > 4) {
		numIncorrect = 0;
		[[UIApplication sharedApplication] performSelector:@selector(terminateWithSuccess)];
        
	}
}

- (void)ocPinPad:(OCPinPad *)opp didEnterNewPin:(NSString *)newPin {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstLaunch"];
	
	[[NSUserDefaults standardUserDefaults] setValue:newPin forKey:@"pin"];
	
	
	/*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Mobile Office is setup!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	*/
	//self.pin = newPin;
	[self dismissModalViewControllerAnimated:YES];
    
    //[self openSettingsViewController];
    [self performSelector:@selector(openSettingsViewController)
                     withObject:nil
                     afterDelay:1.0];
    
}



@end
