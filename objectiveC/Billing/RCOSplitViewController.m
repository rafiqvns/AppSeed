//
//  RCOSplitViewController.m
//  MobileOffice
//
//  Created by .R.H. on 5/9/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "RCOSplitViewController.h"
#import "RCODataViewController.h"

#import "Settings.h"

#define DRAGVIEW_WID 68
#define DRAGVIEW_DETAILOVERLAY 0

#define TAG_SAVE 71001

@interface MGSplitViewController (MGPrivateMethods)

- (void)setup;
- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation;
- (void)layoutSubviews;
- (void)layoutSubviewsWithAnimation:(BOOL)animate;
- (void)layoutSubviewsForInterfaceOrientation:(UIInterfaceOrientation)theOrientation withAnimation:(BOOL)animate;
- (BOOL)shouldShowMasterForInterfaceOrientation:(UIInterfaceOrientation)theOrientation;
- (BOOL)shouldShowMaster;
- (NSString *)nameOfInterfaceOrientation:(UIInterfaceOrientation)theOrientation;
- (void)reconfigureForMasterInPopover:(BOOL)inPopover;

@end

@interface RCOSplitViewController (RCOPrivateMethods)

- (void)setup_dragger;
- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation;
- (void)layoutSubviews;
- (void)layoutSubviewsWithAnimation:(BOOL)animate;
- (void)layoutSubviewsForInterfaceOrientation:(UIInterfaceOrientation)theOrientation withAnimation:(BOOL)animate;

@end

@implementation RCOSplitViewController

@synthesize showDragView=m_showDragView;
@synthesize draggerWid=m_draggerWid;
@synthesize draggerView=m_draggerView;
@synthesize showMasterButton=m_showMasterButton;

#pragma mark - init/destroy
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup_dragger];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self setup_dragger];
	}
	
	return self;
}


- (id) initWithMaster:(RCODataViewController *)mvc andDetail:(UIViewController<MGSplitViewControllerDelegate>*)dvc
{
    if ((self = [super init])) {
        
        dvc.hidesBottomBarWhenPushed = NO;
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:dvc];
    
        mvc.hidesBottomBarWhenPushed = NO;
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:mvc];
        
        self.delegate = dvc;
        self.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        self.showsMasterInPortrait = true;
    
        [self.navigationController.navigationBar setHidden:true];
        
        //mvc.splitController = self;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)setup_dragger
{
}


#pragma mark - View lifecycle

- (void)viewDidUnload
{
    self.draggerView=nil;
    self.showMasterButton=nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark - View Layout
- (void)layoutSubviewsForInterfaceOrientation:(UIInterfaceOrientation)theOrientation withAnimation:(BOOL)animate
{
    UINavigationController *masterNavController = (UINavigationController *) self.masterViewController;
    UIViewController *vc =masterNavController.topViewController;
    UIView *masterView = vc.view;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonPressed:)];
    
    masterNavController.topViewController.navigationItem.leftBarButtonItem = backButton;
    
    [super layoutSubviewsForInterfaceOrientation: theOrientation withAnimation:animate];
    
    CGRect divRect = masterView.frame;
    
    
    Boolean bHasFrame = NO;
    
    if( [vc isKindOfClass:[RCODataViewController class]] ) {
        RCODataViewController *rvc = ( RCODataViewController *) vc;
        bHasFrame = (rvc.frame != nil);
    }
    
#define DRAGGER_OFFSET 44
#define FRAME_WID 12
    
    if ([self isVertical]) {
        
		divRect.origin.x = divRect.origin.x + masterNavController.view.frame.size.width -(self.draggerWid - DRAGVIEW_DETAILOVERLAY);
        // there must be a better way...
        divRect.origin.y = DRAGGER_OFFSET;
    
        if( !bHasFrame ) {
            divRect.size.height += 2 * FRAME_WID;
            divRect.origin.y -= FRAME_WID;
        }
        divRect.size.width = self.draggerWid;
	} else {
		divRect.origin.y = divRect.origin.y + masterNavController.view.frame.size.height - (self.draggerWid - DRAGVIEW_DETAILOVERLAY);
		divRect.size.height = self.draggerWid;
	}
    
    UIView *theView = m_draggerView;
    
#ifdef IOS_7
    
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        
        UIScreen *screen = [UIScreen mainScreen];

        CGRect fullScreenRect = screen.bounds; // always implicitly in Portrait orientation.
        CGRect appFrame = screen.applicationFrame;
        
        // Find status bar height by checking which dimension of the applicationFrame is narrower than screen bounds.
        // Little bit ugly looking, but it'll still work even if they change the status bar height in future.
        float statusBarHeight = MAX((fullScreenRect.size.width - appFrame.size.width), (fullScreenRect.size.height - appFrame.size.height));

        divRect.origin.y += statusBarHeight;
    }
#endif

    theView.frame = divRect;
    
    if( ![theView superview] )
        [self.view addSubview:theView];
}



- (void) hideMaster: (id) sender
{
    
    [UIView animateWithDuration:0.1f animations:
     ^{
         
         self.showsMasterInLandscape = false;
         self.showsMasterInPortrait = false;
         
         UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                        style:UIBarButtonItemStylePlain 
                                                                       target:self
                                                                       action:@selector(backButtonPressed:)];
         UIBarButtonItem *masterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"expand.png"]
                                                                        style:UIBarButtonItemStylePlain 
                                                                       target:self 
                                                                       action:@selector(showMaster:)];
         
         masterButton.width = 36;
         
         if( [[self.detailViewController class] isKindOfClass:[UINavigationController class]]) {
             UIViewController *dvc = ((UINavigationController *)self.detailViewController).topViewController;
             dvc.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: backButton, masterButton, nil];
         }
         masterButton.width = 36;
         
         
     
     }];
}


- (void) showMaster: (id) sender
{
         self.showsMasterInLandscape = true;
         self.showsMasterInPortrait = true;
         [self.view bringSubviewToFront:self.draggerView];
         
        if( [[self.detailViewController class] isKindOfClass:[UINavigationController class]]) {
            UIViewController *dvc = ((UINavigationController *)self.detailViewController).topViewController;
        
            dvc.navigationItem.leftBarButtonItems = [NSArray array];
        }
}

-(void) backButtonPressed: (id) sender
{

        [self _goBack];
}

-(void)_goBack {
    for( UINavigationController *navController in self.viewControllers ) {
        if( [[navController class] isKindOfClass:[UINavigationController class]]) {
            
            if( [[navController.topViewController class] isSubclassOfClass:[RCODataViewController class]]) {
                RCODataViewController *controller = (RCODataViewController *)navController.topViewController;
                if ([controller isKindOfClass:[RCODataViewController class]]) {
                    //controller.splitController = nil;
                    controller.fieldEditingDelegate = nil;
                    
                    [[controller aggregate] unRegisterForCallback: controller];
                }
            }
        }
    }
    
    [Settings save];
    
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:nil afterDelay:0.0];
}

#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_SAVE) {
        if (buttonIndex == 0) {
            // YES, the user wants to save the item
            [[NSNotificationCenter defaultCenter] postNotificationName:@"saveItem" object:nil];
        } else if (buttonIndex == 1) {
            // NO, the user does not want to save the item
            [self _goBack];
        }
    }
}

@end
