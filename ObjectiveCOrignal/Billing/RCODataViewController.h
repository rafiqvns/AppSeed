//
//  RCODataViewController.h
//  MobileOffice
//
//  Created by .R.H. on 11/9/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Aggregate.h"
#import "RCOFieldEditorViewController.h"
#import "RCOSplitViewController.h"


@interface RCODataViewController : RCOFieldEditorViewController <RCODataDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate>
{
    // support for rotating view
    UIImageView *m_background;
    UIImageView *m_frame;
    UIToolbar *m_toolbar;
    
    // mapping
    MKMapView *m_mapView;
    
    // lists
    UITableView *m_categoryTable;
    UITableView *m_recordTable;
    
    // search
    UISearchBar *m_search;
    NSString *m_searchTerm;
    BOOL m_isSearching;
    
    // progress of background download
    UIView *m_progressView;
    UILabel *m_progressLabel;
    UIProgressView *m_progress;
    UIBarButtonItem *m_progressCancelButton;
    long long m_bytesToDo;
    long long m_bytesDone;
    long m_thingsToDo;
    long m_thingsDone;
}

@property (nonatomic, strong) IBOutlet UIImageView *background;
@property (nonatomic, strong) IBOutlet UIImageView *frame;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
#ifndef APP_CSD
@property (nonatomic, strong) IBOutlet Annotation *annotation;
#endif

@property (nonatomic, strong) IBOutlet UITableView *categoryTable;
@property (nonatomic, strong) IBOutlet UITableView *recordTable;

@property (nonatomic, strong) IBOutlet UISearchBar *search;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, assign) BOOL isSearching;

@property (nonatomic, strong) IBOutlet UIView *progressView;
@property (nonatomic, strong) IBOutlet UILabel *progresslabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progress;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *progressCancelButton;

@property (nonatomic, assign) long long bytesToDo;
@property (nonatomic, assign) long long bytesDone;
@property (nonatomic, assign) long thingsToDo;
@property (nonatomic, assign) long thingsDone;


- (Aggregate *) aggregate;

- (void) setMapToLat: (double) latitude andLon: (double) longitude withTitle: (NSString *) titleText andDetail: (NSString *) detailText;

- (void) setImagesForOrientation: (UIInterfaceOrientation)interfaceOrientation;

- (IBAction)resync:(id)sender;

- (void) startDelayedSelection: (NSString *) objId;
- (void) finishDelayedSelection: (NSString *) objId;

// search, possibley more than one search bar
- (void)resetSearch;
- (void)resetSearch: (UISearchBar *)searchBar;
- (void)handleSearchForTerm:(NSString *)searchTerm ;
- (void)handleSearchForTerm:(NSString *)searchTerm inSearchBar: (UISearchBar *)searchBar;

// progress
- (void) bytesAvailable: (NSNumber *) bytes forObject: (RCOObject *) obj;
- (void) bytesAvailable: (NSNumber *) bytes forObjectId: (NSString *) objId;
- (void) bytesInfoAvailable: (NSDictionary *) bytesInfo forObjectId: (NSString *) objId;

- (void) setProgressVisible: (BOOL) isVisible;
- (IBAction) progressCancelButtonPressed:(id)sender;
- (void)RCOSpliterSelectedObject:(RCOObject*)object;

@end
