//
//  MyViewController.h
//  Billing3
//
//  Created by Thomas Smallwood on 8/7/11.
//  Copyright 2011 RCO All rights reserved.

#import <UIKit/UIKit.h>

@protocol LaunchpadMenuDelegate;

@interface LaunchpadMenuViewController : UIViewController {
	UILabel *pageNumberLabel;
    int pageNumber;
    
    UIView *viewPortrait1;
    UIView *viewPortrait2;
    
    id<LaunchpadMenuDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UILabel *pageNumberLabel;
@property (nonatomic, retain) IBOutlet UIView *viewPortrait1;
@property (nonatomic, retain) IBOutlet UIView *viewPortrait2;

@property (nonatomic, retain) IBOutlet UIView *viewLandscape1;
@property (nonatomic, retain) IBOutlet UIView *viewLandscape2;

@property (nonatomic, retain) NSArray *launchPadRectArray;
@property (nonatomic, retain) NSArray *launchPadLandscapeRectArray;

@property (nonatomic, assign) id<LaunchpadMenuDelegate> delegate;

- (id)initWithPageNumber:(int)page;
- (UIView *)pageControlViewWithIndex:(NSUInteger)index;
- (IBAction)launchClientListViewController:(id)sender;
- (IBAction)launchStaffListViewController:(id)sender;
- (IBAction)launchVendorsListViewController:(id)sender;
- (IBAction)launchInvoicesListViewController:(id)sender;
- (IBAction)launchPaymentsListViewController:(id)sender;
- (IBAction)launchPartsListViewController:(id)sender;
- (IBAction)launchChartsListViewController:(id)sender;
- (IBAction)launchReportsListViewController:(id)sender;
- (IBAction)launchTimecardsListViewController:(id)sender;
- (IBAction)launchSettingsViewController:(id)sender;
- (IBAction)launchClipboardViewController:(id)sender;
- (IBAction)launchLegalViewController:(id)sender;
- (IBAction)launchStoreListViewController:(id)sender;


@end

@protocol LaunchpadMenuDelegate <NSObject>

@optional

- (void)openVendorsListViewController;
- (void)openStaffListViewController;
- (void)openClientListViewController;
- (void)openSettingsViewController;
- (void)openTimecardsViewController;
- (void)openPartsListViewController;
- (void)openStoreViewController;

@end
