//
//  LaunchMenuViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 4/14/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DACircularProgress/DACircularProgressView.h>
//#import "DACircularProgressView.h"
#import "BaseViewController.h"
#import "ServerManager.h"
#import "HelperUtility.h"
#import "TrainingCompanyAggregate.h"
#import "TrainingCompany+CoreDataClass.h"
#import "TrainingStudent+CoreDataClass.h"
#import "TrainingDriverStudentAggregate.h"



@interface LaunchMenuViewController : BaseViewController <UIScrollViewDelegate, UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    NSUInteger numIncorrect;
    NSMutableArray *_viewsArrayPortrait;
    NSMutableArray *_viewsArrayLandscape;
    NSMutableArray *_menuItems;
    NSMutableArray *_menuItemsNames;
    NSMutableArray *_menuItemsTags;
    NSInteger _currentPage;
    
    DACircularProgressView *_cpPortrait;
    DACircularProgressView *_cpLandscape;
    UILabel *_recordLabelPortrait;
    UILabel *_recordLabelLandscape;
    UILabel *_fileLabelPortrait;
    UILabel *_fileLabelLandscape;
}

@property (nonatomic, strong) IBOutlet UIView *portraitView;
@property (nonatomic, strong) IBOutlet UIView *landscapeView;
@property (nonatomic, strong) IBOutlet UIScrollView *portraitScroll;
@property (nonatomic, strong) IBOutlet UIPageControl *portraitControl;
@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;

@property (nonatomic, strong) DACircularProgressView *cpPortrait;
@property (nonatomic, strong) DACircularProgressView *cpLandscape;
@property (nonatomic, strong) UILabel *recordLabelPortrait;
@property (nonatomic, strong) UILabel *fileLabelPortrait;
@property (nonatomic, strong) UILabel *recordLabelLandscape;
@property (nonatomic, strong) UILabel *fileLabelLandscape;

@property (nonatomic, strong) NSTimer  *mTimer;


+ (LaunchMenuViewController *)sharedInstance;

- (IBAction)changePage:(id)sender;


@end
