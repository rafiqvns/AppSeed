//
//  RCODataViewController.m
//  MobileOffice
//
//  Created by .R.H. on 11/9/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "RCODataViewController.h"
#import "DataRepository.h"
#import "Settings.h"

@implementation RCODataViewController

@synthesize background = m_background;
@synthesize frame = m_frame;
@synthesize bottomToolbar = m_toolbar;

@synthesize mapView = m_mapView;
#ifndef APP_CSD
@synthesize annotation=m_annotation;
#endif
@synthesize search=m_search;
@synthesize searchTerm=m_searchTerm;
@synthesize isSearching=m_isSearching;

@synthesize categoryTable=m_categoryTable;
@synthesize recordTable=m_recordTable;

@synthesize progressView=m_progressView, progress=m_progress, progresslabel=m_progressLabel, progressCancelButton=m_progressCancelButton;
@synthesize bytesToDo=m_bytesToDo, bytesDone=m_bytesDone, thingsToDo=m_thingsToDo, thingsDone=m_thingsDone;

#pragma mark - Init/Destroy

- (void)didReceiveMemoryWarning
{
    NSLog(@"didReceiveMemoryWarning: %@-%@", self.class, self);
    //[aggregate unRegisterForCallback:self];
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [super viewWillAppear:animated];
    [[self aggregate] registerForCallback:self];
}

- (void)viewWillDisappear:(BOOL)animated {    
    if( [self.navigationController.viewControllers count] == 1 && DEVICE_IS_IPAD && 
       ([[[[self.navigationController.viewControllers objectAtIndex:0] class] description] hasPrefix:@"Launch"]))
       
    {
        NSLog(@"%@", [self.navigationController.viewControllers objectAtIndex:0]);
        [self.navigationController.navigationBar setHidden:YES];
        [[self aggregate] unRegisterForCallback:self];
    }
    
    [super viewWillDisappear:animated];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"viewDidLoad: %@", self.class);
    [[self aggregate] registerForCallback:self];
    [self setImagesForOrientation:self.interfaceOrientation];
    
    [super viewDidLoad];
}

// this is mainly called so that aggregate will release reference to view before viewDidUnload
- (void)viewWillUnload
{
    NSLog(@"viewWillUnload: %@", self.class);
    //[aggregate unRegisterForCallback:self];

    [super viewWillUnload];    
}

- (void)viewDidUnload
{
    NSLog(@"viewDidUnload: %@", self.class);
    [[self aggregate] performSelector:@selector(unRegisterForCallback:)
                     withObject:self
                     afterDelay:1.0];
    
    self.background=nil;
    self.frame=nil;
    self.bottomToolbar=nil;
    
    self.mapView=nil;
    self.search=nil;
    self.searchTerm=nil;
    self.recordTable=nil;
    self.categoryTable=nil;
    
    self.progresslabel=nil;
    self.progressView=nil;
    self.progress=nil;

    [super viewDidUnload];
}

#pragma mark - Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if( DEVICE_IS_IPAD )
        //return TRUE;
        return (interfaceOrientation == UIInterfaceOrientationPortrait ||
                interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
        else
        return (interfaceOrientation == UIInterfaceOrientationPortrait ||
                interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setImagesForOrientation:toInterfaceOrientation];
}

- (void) setImagesForOrientation: (UIInterfaceOrientation)interfaceOrientation
{

}

#pragma mark - Progress
- (void) setProgressVisible: (BOOL) isVisible
{
    self.progress.hidden = !isVisible;
    
    if( isVisible && self.progressCancelButton==nil ) {
        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                             target:self 
                                                                             action:@selector(progressCancelButtonPressed:)];
        btn.style = UIBarButtonItemStylePlain;
        NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
        self.progressCancelButton = btn;
        
        [newItems addObject:self.progressCancelButton];
        [self.bottomToolbar setItems:newItems animated:true];
        
    }
    else if( !isVisible && (self.progressCancelButton!=nil)) {
        //[self.progressCancelButton 
        NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
        [newItems removeLastObject];
        
        [self.bottomToolbar setItems:newItems animated:true];
        self.progressCancelButton = nil;
    }
    
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (void) setMapToLat: (double) latitude andLon: (double) longitude withTitle: (NSString *) titleText andDetail: (NSString *) detailText {
#ifndef APP_CSD
    // we should remove the annotations that were previously added
    NSArray *annotations = [self.mapView annotations];
    
    if ([annotations count]) {
        [self.mapView removeAnnotations:annotations];
    }
    
    CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    self.annotation = [Annotation annotationWithCoordinate:currentLocation.coordinate];
    self.annotation.title    = titleText;
    self.annotation.subtitle = detailText;
    
    if (nil != self.annotation) {
        
        [self.mapView addAnnotation:self.annotation];
        
        self.annotation = nil;
    }
    
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    
    region.center = currentLocation.coordinate;
    
    region.span.longitudeDelta = 0.05f;
    region.span.latitudeDelta  = 0.05f;
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
#endif
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.search resignFirstResponder];
    self.search.text = @"";
    if( tableView != self.categoryTable )
    {
        [tableView reloadData];        
    }
    return indexPath;	
}
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = [searchBar text];
    [self handleSearchForTerm:searchTerm inSearchBar:searchBar];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm {
    if ([searchTerm length] == 0) {
        [self resetSearch];
       // [table reloadData];
        return;
    }
    [self handleSearchForTerm:searchTerm inSearchBar:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    searchBar.text = @"";
    [self resetSearch];
    //[table reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
    //[table reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.isSearching = NO;
    //[table reloadData];
}

#pragma mark -
#pragma mark Search Methods
- (void)resetSearch {
   
    self.searchTerm = @"";
    
    [self objectSyncComplete:self.aggregate];
}

- (void)handleSearchForTerm:(NSString *)searchTerm inSearchBar:(UISearchBar *) searchBar {
    self.searchTerm = searchTerm;
    
    [self objectSyncComplete:self.aggregate];
}

- (void) objectSyncComplete: (Aggregate *) fromAggregate {
    NSLog(@"fix the object sync complete issue");
}

#pragma mark - RCODataView
- (void) startDelayedSelection:(NSString *) objId
{
    NSLog(@"startDelayedSelection %@", objId);
    [self performSelector:@selector(finishDelayedSelection:)
               withObject:objId
               afterDelay:0.1];
     
}

- (void) finishDelayedSelection: (NSString *) objId
{
    
}

- (IBAction)resync:(id)sender
{
    
    [self showSimpleMessage:@"Synchronization process started. For more informations please check Synchronization Status" andTitle:NSLocalizedString(@"Notification", nil)];
    
    [[DataRepository sharedInstance] syncStop];
    
    // override?
    [[DataRepository sharedInstance] getUserInfo];

}

#pragma mark - Progress
- (void) bytesAvailable: (NSNumber *) bytes forObject: (RCOObject *) obj
{
    
}

- (IBAction) progressCancelButtonPressed:(id)sender;
{
    
}

- (Aggregate *) aggregate
{
    return nil;
}

#pragma mark - Split View Delegate
// Called when a button should be added to a toolbar for a hidden view controller.
- (void)splitViewController:(MGSplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController 
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc
{
    
}

// Called when the master view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(MGSplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
}

-(void)RCOSpliterWillSelectedObject:(RCOObject *)object
{
    
}

-(void)RCOSpliterSelectedObject:(RCOObject*)object
{
    
}

-(void)RCOSpliterSelectedObjectDict:(NSDictionary*)objectDict
{
    // TODO: Unimplemented
}

-(void)RCOSpliterWillSelectedObjectDict:(NSDictionary*)objectDict
{
   
}
@end
