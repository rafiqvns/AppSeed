//
//  PhotosViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 11/21/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "PhotosViewController.h"
#import "DataRepository.h"
#import "Photo+Photo_Imp.h"
#import "PhotosAggregate.h"
#import "BillingAppDelegate.h"

#import <MWPhotoBrowser/MWPhotoBrowser.h>

#import "UIImage+Resize.h"

#define TAG_FULL_SYNC 1002

#define ImageSizeThumb @"200"
#define ImageSizeFull @"-1"

@interface PhotosViewController ()

@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) UIImage *nextImage;
@property (nonatomic, strong) UIImage *prevImage;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) BOOL loadLastImage;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *photosToRemove;
@property (nonatomic, strong) NSMutableArray *photosToRemoveFromRMS;
@property (nonatomic, strong) NSMutableArray *photosToAdd;

@end

@implementation PhotosViewController

@synthesize addImageButton;
@synthesize pagingScrollView;
@synthesize pageControl;
@synthesize bottomToolbar;
@synthesize removeImageButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil items:(NSArray*)items selectedIndex:(NSInteger)index
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _items = items;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.progressHUD.labelText = @"Loading Photos...";
    
    self.progressHUD.dimBackground = YES;
    [self.view addSubview:self.progressHUD];
    [self.progressHUD show:YES];

    
    self.photosToRemove = [NSMutableArray array];
    self.photosToRemoveFromRMS = [NSMutableArray array];
    self.photosToAdd = [NSMutableArray array];
    
    //[self performSelectorInBackground:@selector(loadImages:) withObject:[NSNumber numberWithInt:self.currentImageIndex]];
    
    self.currentImageIndex = 0;

    [self loadImages:[NSNumber numberWithInteger:self.currentImageIndex]];
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem = closeBtn;
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(savePressed:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    pagingScrollView.pagingEnabled = YES;
    
    pageControl.numberOfPages = [self imageCount];
    pageControl.currentPage = 0;
    
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages  = [[NSMutableSet alloc] init];
    
    [self tilePages];
    
    self.title = @"Photos";
    
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTap)];
    
    // Set required taps and number of touches
    [oneTap setNumberOfTapsRequired:1];
    [oneTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the view
    [[self pagingScrollView] addGestureRecognizer:oneTap];

    _isNavigationBarShown = YES;
    
    if (![self.photosParentObject existsOnServerNew] && !self.recordId) {
        [[DataRepository sharedInstance].photosAggregate getPhotosForObject:self.photosParentObject];
    } else if ([self.photosParentObject existsOnServer] || self.recordId) {
        //[[DataRepository sharedInstance].photosAggregate getChildrenDirectoryIds:self.photosParentObject childrenType:@"Photo"];
        if (self.recordId) {
            [[DataRepository sharedInstance].photosAggregate getChildrenDirectoryIdsByRecordId:self.recordId childrenType:@"Job Photo"];
        } else {
            if (self.usePhotoRecord) {
                [[DataRepository sharedInstance].photosAggregate getPhotosForMasterBarcode:self.photosParentObject.rcoBarcode];
            } else {
                [[DataRepository sharedInstance].photosAggregate getChildrenDirectoryIds:self.photosParentObject childrenType:@"Job Photo"];
            }
        }
    } else {
        // the invoice was not saved on the server, so there is no point in trying to get the photos for the pinvoice
        NSLog(@"The invoice shol be saved st!");
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.aggregate registerForCallback:self];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self willAnimateRotationToInterfaceOrientation:orientation duration:0.1];
    if (self.loadLastImage) {
        [self loadImages:[NSNumber numberWithInteger:self.currentImageIndex]];
        pageControl.currentPage = [self currentPage];
        [self tilePages];
        self.loadLastImage = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.recordId) {
        
    } else if (![self.photosParentObject existsOnServer]) {
        [self.progressHUD hide:YES];
        //[self showSimpleMessage:@"The invoice is not saved! There are no photos on the server!" andTitle:NSLocalizedString(@"Notification", nil)];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.aggregate unRegisterForCallback:self];
}

-(void)oneTap {
    [self.navigationController setNavigationBarHidden:_isNavigationBarShown];
    _isNavigationBarShown = !_isNavigationBarShown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    //pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
    // place to calculate the content offset that we will need in the new orientation
    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    
    if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // adjust frames and configuration of each visible page
    for (ImageScrollView *page in visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    if (self.loadLastImage) {
        firstVisiblePageIndexBeforeRotation = (int)self.currentImageIndex;
    }
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"Center = %@", NSStringFromCGPoint(self.view.center));
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
       
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
        [self willAnimateRotationToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
        
    } completion:nil];

}

-(void)imageLoaded:(NSNumber*)imageIndex {
    
    if ([imageIndex integerValue] == self.currentImageIndex) {
        [self setCurrentPage:[imageIndex intValue]];
    }
    
    ImageScrollView* page = [self isDisplayingPageForIndex:[imageIndex integerValue]];
    page.totalPages = [_photos count];
    
   /* if (nil != page)*/ {
        [self configurePage:page forIndex:[imageIndex integerValue]];
    }
    
    pagingScrollView.userInteractionEnabled = YES;
}

#pragma mark -
#pragma mark Tiling and page configuration

- (void)tilePages
{
    // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    // Recycle no-longer-visible pages
    for (ImageScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (nil == [self isDisplayingPageForIndex:index]) {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[ImageScrollView alloc] init];
            }
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }
}

- (ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        /*
         TODO_ARC
        [[page retain] autorelease];
        */
        [recycledPages removeObject:page];
    }
    return page;
}

- (ImageScrollView *) isDisplayingPageForIndex:(NSUInteger)index
{
    ImageScrollView* foundPage = nil;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = page;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    
    [page displayImage:[self imageAtIndex:index]];
}


- (int) currentPage {
    CGFloat pageWidth = pagingScrollView.frame.size.width;
    CGFloat halfPageWidth = pageWidth / 2;
    CGFloat xOffset = pagingScrollView.contentOffset.x;
    int currentPage = floor((xOffset - halfPageWidth) / pageWidth) + 1;
    
    if (self.currentImageIndex != currentPage) {
        
        NSInteger currentIndex = self.currentImageIndex;
        
        self.currentImageIndex = currentPage;
        
        if ((currentPage > 0) && (currentPage < ([/*self.imagesPath*/self.photos count] - 1 ))) {
            pagingScrollView.userInteractionEnabled = NO;
        }
        
        if (currentPage < currentIndex) {
            self.nextImage = self.currentImage;
            self.currentImage = self.prevImage;
            self.prevImage = nil;
            // configure next image
            
            ImageScrollView* page = [self isDisplayingPageForIndex:currentIndex];
            if (nil != page) {
                [self configurePage:page forIndex:currentIndex];
            }
            
        } else if (currentPage > currentIndex) {
            self.prevImage = self.currentImage;
            self.currentImage = self.nextImage;
            self.nextImage = nil;
            // configure prev image
            
            ImageScrollView* page = [self isDisplayingPageForIndex:currentIndex];
            if (nil != page) {
                [self configurePage:page forIndex:currentIndex];
            }
        }
        
        ImageScrollView* page = [self isDisplayingPageForIndex:currentPage];
        if (nil != page) {
            [self configurePage:page forIndex:currentPage];
        }
        
        [self performSelectorInBackground:@selector(loadImages:) withObject:[NSNumber numberWithInteger:currentIndex]];
    }
    self.currentImageIndex = currentPage;
    
    return currentPage;
}

- (void) setCurrentPage:(int) page {
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    CGFloat newOffset = page * pageWidth;
    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
    
}



#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    pageControl.currentPage = [self currentPage];
    [self tilePages];
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}


- (IBAction)changePage:(id)sender
{
    int page = (int)pageControl.currentPage;
	[self setCurrentPage:page];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

#pragma mark -
#pragma mark  Frame calculations
#define PADDING  10

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    pageFrame.size.height -= 20;
    
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self imageCount], bounds.size.height);
}

#pragma mark -
#pragma mark Image wrangling

- (UIImage *)imageAtIndex:(NSUInteger)index {
    
    if (index >= self.photos.count) {
        return nil;
    }
    
    NSObject *obj = [self.photos objectAtIndex:index];
    
    UIImage *img = nil;
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        
        RCOObject *rcoObj = [_items objectAtIndex:index];
        NSString *objectId = rcoObj.rcoObjectId;

        /* 21.04.2017  old
         img = [[self aggregate] getImageForObject:objectId];
         */
        
        //NSData *imgData = [[self aggregate] getDataForObject:objectId size:@"-1" skipDownload:YES];
        //NSData *imgData = [[self aggregate] getDataForObject:objectId size:ImageSizeThumb skipDownload:YES];
        NSData *imgData = [[self aggregate] getDataForObject:objectId size:ImageSizeFull skipDownload:YES];
        
        if (imgData) {
            img = [[UIImage alloc] initWithData:imgData];
            //img = [[self aggregate] getImageForObject:objectId];
        } else {
            //img = [[self aggregate] getImageForObject:objectId];
            img = [[self aggregate] getImageForObject:objectId size:[ImageSizeThumb intValue]];
            if (img) {
                // we should try to download the full image also
                [[DataRepository sharedInstance].photosAggregate jumpstartDataDownloadForced:objectId];
            }
        }
        
        BOOL isOffline = [[DataRepository sharedInstance] workOffline];

        if (!img && isOffline)  {
            //27.02.2018 if we are offline then we should try to load the image based on the mobile record id
            img = [[self aggregate] getImageForObject:rcoObj.rcoMobileRecordId];
        }
        
        //image = [[UIImage alloc] initWithData:theData];
        
        if (img) {
            [self.photos replaceObjectAtIndex:index withObject:img];
        } else {
            // start downloading the photo
            if (rcoObj.rcoObjectId) {
                
                
                NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
                NSManagedObjectContext *context = [threadDict objectForKey:kMobileOfficeKey_MOC];
                
                NSPersistentStoreCoordinator *coordinator = [[DataRepository sharedInstance] persistentStoreCoordinator];
                
                if( context == nil ) {
                    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
                    [context setPersistentStoreCoordinator:coordinator];
                    [context setMergePolicy:NSOverwriteMergePolicy];
                    
                    [threadDict setObject:context forKey:kMobileOfficeKey_MOC];
                }

                //[[DataRepository sharedInstance].photosAggregate downloadDataForObject:rcoObj.rcoObjectId size:@"-1"];
                [[DataRepository sharedInstance].photosAggregate downloadDataForObject:rcoObj.rcoObjectId size:ImageSizeThumb];
                
            }
        }
    } else {
        img = (UIImage*)obj;
    }
    
    return img;
    
    if (index == self.currentImageIndex) {
        return self.currentImage;
    } else if (index < self.currentImageIndex) {
        return self.prevImage;
    } else {
        return self.nextImage;
    }
}

- (NSUInteger)imageCount {
    return [self.photos count];
    //return [managedThumbnailObjects count];
}

-(void)loadImages:(NSNumber*)index {

    if (self.photos.count == 0) {
        self.photos =  [NSMutableArray array];
        
        for (int i = 0; i < _items.count; i++) {
            [self.photos addObject:[NSNumber numberWithBool:NO]];
        }
    }
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

    [self imageLoaded:index];
}

#pragma mark Actions

-(void)resaveCurrentSelectedPhoto {
    
    if (self.currentImageIndex < _items.count) {
        RCOObject *obj = [_items objectAtIndex:self.currentImageIndex];
        
        if ([obj isKindOfClass:[Photo class]]) {
            Photo *photoToSave = (Photo*)obj;
            
            PhotosAggregate *photoAgg = (PhotosAggregate*)self.aggregate;

            photoToSave.fileIsDownloading = nil;
            photoToSave.fileIsUploading = nil;
            photoToSave.fileNeedsDownloading = nil;
            photoToSave.fileNeedsUploading = [NSNumber numberWithBool:YES];

            photoToSave.objectIsDownloading = nil;
            photoToSave.objectIsUploading = nil;
            photoToSave.objectNeedsDownloading = nil;
            photoToSave.objectNeedsUploading = [NSNumber numberWithBool:YES];

            [photoAgg save];
            [photoAgg createNewRecord:photoToSave];
        }
    } else {
        [self showSimpleMessage:@"Please Save the Photos first!"];
    }
}

-(void)savePressed:(id)sender {
    
    PhotosAggregate *photoAgg = (PhotosAggregate*)self.aggregate;
    Aggregate *photoParentAgg = nil;
    if (self.photosParentObject) {
        photoParentAgg = [[DataRepository sharedInstance] getAggregateForClass:self.photosParentObject.rcoObjectClass];
    }
    
    NSMutableArray *photos = [NSMutableArray array];
    
    for (UIImage *img in self.photosToAdd) {
        Photo *newPhoto = (Photo*)[photoAgg createNewObject];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
        
        BOOL isTicketGRower = NO;
        
        
        if (isTicketGRower) {
        } else {
            newPhoto.name = [NSString stringWithFormat:@"photo_%@", [dateFormat stringFromDate:[NSDate date]]];
            newPhoto.title = [NSString stringWithFormat:@"photo_%@", [dateFormat stringFromDate:[NSDate date]]];
            NSString *category = nil;
            
            if ([self.photosParentObject respondsToSelector:@selector(category)]) {
                category = [self.photosParentObject valueForKey:@"category"];
            }
            
            newPhoto.category = category;

        }
        newPhoto.dateTime = [NSDate date];
        newPhoto.latitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLatitude]];
        newPhoto.longitude = [NSString stringWithFormat:@"%@", [[DataRepository sharedInstance] getCurrentLongitude]];
        
        newPhoto.itemType = ItemTypePhoto;

        // set the parent
        if (self.recordId) {
            // we should use the new call that uses recordId
            newPhoto.parentObjectId = self.recordId;
            newPhoto.parentObjectType = RCO_OBJECT_TYPE_RECORD_ID;
        } else {
            if ([self.photosParentObject existsOnServerNew]) {
                newPhoto.parentObjectId = self.photosParentObject.rcoObjectId;
                newPhoto.parentObjectType = self.photosParentObject.rcoObjectType;
                newPhoto.parentBarcode = self.photosParentObject.rcoBarcode;
            } else {
                newPhoto.parentObjectId = self.photosParentObject.rcoObjectId;
                newPhoto.parentObjectType = self.photosParentObject.rcoObjectClass;
                newPhoto.parentBarcode = nil;
                // add the link of the new photo to the photo parent record
                [self.photosParentObject addLinkedObject:newPhoto.rcoMobileRecordId];
                [photoParentAgg save];
            }
        }
        
        [newPhoto setContentNeedsUploading:YES];
        [newPhoto setFileNeedsUploading:[NSNumber numberWithBool:YES]];

        [photoAgg save];
        [photoAgg createNewRecord:newPhoto];
        [self savePicture:img forPhoto:newPhoto];
        
        [photos addObject:newPhoto];
    }
    
    for (RCOObject *obj in self.photosToRemoveFromRMS) {
        
        NSString *objId = obj.rcoObjectId;
        
        if (objId) {
            RCOObject *objToDelete = [photoAgg getObjectWithId:objId];
            if (objToDelete) {
                [self.aggregate destroyObj:objToDelete];
            }
        }
    }
    
    if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.selectDelegate didAddObject:photos forKey:self.selectDelegateKey];
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

-(void)closePressed:(id)sender {
    if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.selectDelegate didAddObject:nil forKey:nil];
    }
}

- (IBAction)addImage {
    UIActionSheet *actionSheet = nil;
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Photo"
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                destructiveButtonTitle:nil
                                     otherButtonTitles:NSLocalizedString(@"Take new photo", nil), NSLocalizedString(@"Pick existing image", nil), nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

    if (DEVICE_IS_IPAD) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
    }
}

- (IBAction)deleteImage {
    
    NSLog(@"delete image = %d", (int)self.currentImageIndex);
    
    if (self.photos.count == 0) {
        [self showSimpleMessage:@"There are no photos" andTitle:NSLocalizedString(@"Notification", nil)];
        return;
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];

    UIImage *img = [self.photos objectAtIndex:self.currentImageIndex];
    
    if ([self.photosToAdd containsObject:img]) {
        [self.photosToAdd removeObject:img];
    } else {
        if (self.currentImageIndex < _items.count) {
            RCOObject *obj = [_items objectAtIndex:self.currentImageIndex];
            if (obj) {
                [self.photosToRemoveFromRMS addObject:obj];
            }
        }
    }
    
    [self.photos removeObjectAtIndex:self.currentImageIndex];

    if (self.currentImageIndex < self.photos.count) {
    } else {
        self.currentImageIndex = (self.photos.count - 1);
        if (self.currentImageIndex < 0) {
            self.currentImageIndex = 0;
        }
    }

    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    [self tilePages];
    
    [self imageLoaded:[NSNumber numberWithInteger:self.currentImageIndex]];
    
    pageControl.numberOfPages = [self imageCount];
    
}

-(void)syncNow {
    // we should start a sync
    NSString *message = NSLocalizedString(@"Starting a full sync. Do you want to continue?", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Yes", nil), @"No", nil];
    alert.tag = TAG_FULL_SYNC;
    [alert show];
}

-(void)_syncNow {
    [[DataRepository sharedInstance] fullSyncStart];
}

-(IBAction)actionButtonPressed:(id)sender {
    UIActionSheet *sheet = nil;
        sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", nil)
                                            delegate:self
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Resave current photo", @"Start a full sync", nil];
    
    sheet.tag = SHEET_ACTIONS;
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    if (DEVICE_IS_IPHONE) {
        [sheet showInView:self.view];
    }
    else {
        [sheet  showFromBarButtonItem:(UIBarButtonItem *)sender animated:true];
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate Methods


#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_FULL_SYNC) {
        if (buttonIndex == 0) {
            [self _syncNow];
        }
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == SHEET_ACTIONS) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        switch (buttonIndex) {
            case 0:
                // resave the current photo
                [self resaveCurrentSelectedPhoto];
                break;
            case 1:
                // start full sync
                [self syncNow];
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0:
                [self takePicture];
                break;
            case 1:
                [self choosePicture];
                break;
                /*
                 case 2:
                 if (actionSheet.numberOfButtons > 3) {
                 [self showPhoto];
                 }
                 */
                break;
        }
    }
}

#pragma mark -
#pragma mark Image Methods

- (void)takePicture {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
        if (DEVICE_IS_IPHONE) {
            [self presentModalViewControlleriOS6:picker animated:YES];
        } else {
            UIBarButtonItem *addBtn = self.navigationItem.rightBarButtonItem;

            [self showPopoverForNavigationViewController:picker
                                           fromBarButton:addBtn];
        }
    }
	else
	{
        [self showSimpleMessage:NSLocalizedString(@"Camera is not available", @"Camera is not available") andTitle:NSLocalizedString(@"Error", @"Error") closeButtonName:NSLocalizedString(@"Close", @"Close")];
	}
}

- (void)choosePicture {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
        if (DEVICE_IS_IPHONE) {
            [self presentModalViewControlleriOS6:picker animated:YES];
        } else {

            [self showPopoverForNavigationViewController:picker
                                           fromBarButton:self.addImageButton];
        }
    }
	else
	{
        [self showSimpleMessage:NSLocalizedString(@"Album is not available" , @"Album is not available") andTitle:NSLocalizedString(@"Error", @"Error") closeButtonName:NSLocalizedString(@"Close", @"Close")];
	}
}


- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    NSLog(@"didFinishPickingImage");
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // 31.01.2018 taking a photo sometines was returning a image that was not orientated correctly
    img = [img rotateImage:img];
    

    /*
    if (self.resizeImage) {
        
        NSInteger maxSize = 1024;
        
        CGFloat size = MIN ( img.size.width, img.size.height );
        
        if (size > maxSize) {
            size = maxSize;
        }
        
        CGRect bounds = CGRectMake((img.size.width - size)/2, (img.size.height - size)/2, size, size);
        img = [img croppedImage:bounds];
    }
    */
    
    if (self.resizeImage) {
        CGSize size = CGSizeMake(640, 640);
       // img = [img resizedImage:size interpolationQuality:kCGInterpolationDefault];
        img = [img resizedImage:size interpolationQuality:kCGInterpolationHigh];
    }
    
    
    if (img) {
        [self.photos addObject:img];
        [self.photosToAdd addObject:img];
        //[self setPhotosLabelTitle];
        
        pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
        
        self.currentImageIndex = (self.photos.count - 1);

        [self tilePages];
        
        [self imageLoaded:[NSNumber numberWithInteger:self.currentImageIndex]];
        
        pageControl.numberOfPages = [self imageCount];
        
        [self setCurrentPage:(int)self.currentImageIndex];

        self.pageControl.currentPage = self.currentImageIndex;
        self.loadLastImage = YES;
    }
    [picker dismissModalViewControllerAnimatediOS6:YES];
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void)savePicture:(UIImage*)image forPhoto:(Photo*)photo {
    
    /*16.03.2018 we will not resize the image, we will save as jpeg and set compressio ration at half
     NSData *imageData = UIImagePNGRepresentation(image);
     */
    
    // compression is 0(most)..1(least)
    double compression = 0.5;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    NSLog(@"W = %f H = %f", image.size.width, image.size.height);
    
    /*if (self.recordId) {
        [[self aggregate] saveImage:imageData forRecordId:self.recordId];
    } else*/ {
        [[self aggregate] saveImage:imageData forObjectId:photo.rcoMobileRecordId andSize:kImageSizeForUpload];
        
        BOOL saveThumbnail = YES;
        if (saveThumbnail) {
            CGSize size = CGSizeMake([kImageSizeThumbnailSize integerValue], [kImageSizeThumbnailSize integerValue]);
            image = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];
            NSData *imageData = UIImageJPEGRepresentation(image, compression);
            [[self aggregate]  saveImage:imageData forObjectId:photo.rcoMobileRecordId andSize:kImageSizeThumbnailSize];
        }
    }
}

-(void)requestSucceededForMessage:(NSDictionary*)msgDict fromAggregate:(Aggregate*)aggregate {
    
    NSString *message = [msgDict objectForKey:@"message"];
    
    if ([message isEqualToString:RD_G_R_U_F]) {
        // NSArray *photos = [msgDict objectForKey:@"photos"];
        NSArray *photosIds = [msgDict objectForKey:@"photosObjects"];
        
        NSMutableArray *photosObjects = [NSMutableArray array];
        
        BOOL isOffline = [[DataRepository sharedInstance] workOffline];
        
        // 27.02.2018 if we are working offline we should load just the photos from local DB
        
        if (_items && !isOffline) {
            
            for (NSString *objId in photosIds) {
                Photo *photo = (Photo*)[[self aggregate] getObjectWithId:objId];
                [photosObjects addObject:photo];
            }
            
            _items = photosObjects;
            
            self.photos = [NSMutableArray array];
            [self loadImages:[NSNumber numberWithInt:0]];

            pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
            
            self.currentImageIndex = 0;
            
            [self tilePages];
            
            [self imageLoaded:[NSNumber numberWithInteger:self.currentImageIndex]];
            
            pageControl.numberOfPages = [self imageCount];
        } else if (isOffline) {
            
            if (self.photosParentObject) {
                
                PhotosAggregate *agg = (PhotosAggregate*)aggregate;
                
                NSArray *photosLocally = [agg getPhotosForObject:self.photosParentObject];
                
                if (photosLocally.count) {
                    _items = [[NSMutableArray alloc] initWithArray:photosLocally];
                } else {
                    _items = nil;
                }
                
                self.photos = [NSMutableArray array];
                [self loadImages:[NSNumber numberWithInt:0]];
                self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
                
                self.currentImageIndex = 0;
                
                [self tilePages];
                
                [self imageLoaded:[NSNumber numberWithInteger:self.currentImageIndex]];
                
                self.pageControl.numberOfPages = [self imageCount];
            }
        }
        
        [self.progressHUD hide:YES];
        
    } else if ([message isEqualToString:SET_PHOTOS]){
        
        if (self.photosParentObject) {
            
            PhotosAggregate *agg = (PhotosAggregate*)aggregate;
            
            NSArray *photosLocally = [agg getPhotosForObject:self.photosParentObject];
            
            if (photosLocally.count) {
                _items = [[NSMutableArray alloc] initWithArray:photosLocally];
            } else {
                _items = nil;
            }
            
            self.photos = [NSMutableArray array];
            [self loadImages:[NSNumber numberWithInt:0]];
            self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
            
            self.currentImageIndex = 0;
            
            [self tilePages];
            
            [self imageLoaded:[NSNumber numberWithInteger:self.currentImageIndex]];
            
            self.pageControl.numberOfPages = [self imageCount];
        }
        [self.progressHUD hide:YES];
    }
}

- (void)requestFailedForMessage:(NSDictionary*)messageInfo fromAggregate: (Aggregate *) aggregate {
    NSString *message = [messageInfo objectForKey:@"message"];
    
    if ([message isEqualToString:RD_G_R_U_F]) {
        
                
        if (self.photosParentObject) {
            
            PhotosAggregate *agg = (PhotosAggregate*)aggregate;
            
            NSArray *photosLocally = [agg getPhotosForObject:self.photosParentObject];
            
            if (photosLocally.count) {
                _items = [[NSMutableArray alloc] initWithArray:photosLocally];
            } else {
                _items = nil;
            }
            
            self.photos = [NSMutableArray array];
            [self loadImages:[NSNumber numberWithInt:0]];
            self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
            
            self.currentImageIndex = 0;
            
            [self tilePages];
            
            [self imageLoaded:[NSNumber numberWithInteger:self.currentImageIndex]];
            
            self.pageControl.numberOfPages = [self imageCount];
        }
        
        [self.progressHUD hide:YES];

    }
    [self.progressHUD hide:YES];
}

- (void) objectUploadComplete:(NSString *) objectId fromAggregate: (Aggregate *) aggregate {
    
    Photo *newPhoto = (Photo*)[aggregate getObjectWithId:objectId];
    
    if ([newPhoto contentNeedsUploading]) {
        // we should upload the image
        // we should copy the image that was saved using mobile record Id to object Id
        
        NSURL *imageSourcePath = [aggregate getFilePathForObjectImage:newPhoto.rcoMobileRecordId size:@"-1"];
        NSURL *imageDestPath = [aggregate getFilePathForObjectImage:newPhoto.rcoObjectId size:@"-1"];
        
        NSLog(@"source Path = %@ \n dest path = %@", imageSourcePath, imageDestPath);
        
        NSError *error = nil;
        BOOL copyRes = [[NSFileManager defaultManager] copyItemAtURL:imageSourcePath
                                                               toURL:imageDestPath
                                                               error:&error];
        
        NSLog(@"copy result = %d", copyRes);
        
        //[aggregate uploadObjectContent:newPhoto size:@"-1"];
    }
}

- (void) contentDownloadCompleteWithInfo:(NSDictionary *) info fromAggregate: (Aggregate *) aggregate {

    NSLog(@"info");
    
    NSString *objectId = [info objectForKey:RCOOBJECT_OBJECTID];
    
    if ([objectId length] == 0) {
        return;
    }
    
    NSString *imageThumb = [info objectForKey:RCOOBJECT_CONTENT_SIZE];
    UIImage *image = [[self aggregate] getImageForObject:objectId size:[imageThumb intValue]];
    
    if (nil == image) {
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rcoObjectId=%@", objectId];
    NSArray *filteredItems = [_items filteredArrayUsingPredicate:predicate];
    
    if (filteredItems.count) {
        Photo *photo = [filteredItems objectAtIndex:0];
        NSInteger index = [_items indexOfObject:photo];
        if (index != NSNotFound) {
            [self loadImages:[NSNumber numberWithInteger:index]];
        }
    }
}

- (void) contentDownloadComplete:(NSString *) objectId fromAggregate: (Aggregate *) aggregate {
    
    //UIImage *image = [[self aggregate] getImageForObject:objectId];
    UIImage *image = [[self aggregate] getImageForObject:objectId size:[ImageSizeFull intValue]];
    
    if (nil == image) {
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rcoObjectId=%@", objectId];
    
    NSArray *filteredItems = [_items filteredArrayUsingPredicate:predicate];
    
    if (filteredItems.count) {
        Photo *photo = [filteredItems objectAtIndex:0];
        NSInteger index = [_items indexOfObject:photo];
        
        if (index < self.photos.count) {
            [self.photos replaceObjectAtIndex:index withObject:image];
        }
        if (index != NSNotFound) {
            [self loadImages:[NSNumber numberWithInteger:index]];
        }
    }
}


@end
