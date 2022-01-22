//
//  PhotosViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 11/21/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "ImageScrollView.h"
#import "AddObject.h"


@interface PhotosViewController : HomeBaseViewController <UINavigationBarDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
    UIBarButtonItem *removeImageButton;
    UIBarButtonItem *addImageButton;
    
    UIScrollView *pagingScrollView;
    UIPageControl *pageControl;
    UIToolbar *bottomToolbar;
    
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int           firstVisiblePageIndexBeforeRotation;
    CGFloat       percentScrolledIntoFirstVisiblePage;
    
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    BOOL _isNavigationBarShown;
    
    NSArray *_items;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *removeImageButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addImageButton;
@property (nonatomic, strong) IBOutlet UIScrollView *pagingScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;

@property (nonatomic, strong) RCOObject *photosParentObject;
@property (nonatomic, weak) id<AddObject> selectDelegate;
@property (nonatomic, strong) NSString *selectDelegateKey;

@property (nonatomic, weak) Aggregate *aggregate;
@property (nonatomic, strong) NSString *recordId;

@property (nonatomic, assign) BOOL resizeImage;

@property (nonatomic, assign) BOOL usePhotoRecord;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil items:(NSArray*)items selectedIndex:(NSInteger)index;

- (IBAction)changePage:(id)sender;

- (IBAction)addImage;
- (IBAction)deleteImage;

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index;
- (ImageScrollView *)isDisplayingPageForIndex:(NSUInteger)index;

- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;

- (void)tilePages;
- (ImageScrollView *)dequeueRecycledPage;

- (int) currentPage;

- (NSUInteger)imageCount;
- (UIImage *)imageAtIndex:(NSUInteger)index;


@end
